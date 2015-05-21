class Question < ActiveRecord::Base
  belongs_to :application_template

  DATA_TYPES = %w(text
                  number
                  yes/no
                  date)

  validates :application_template,
            :data_type,
            :name,
            :number,
            :prompt,
            presence: true
  validates :required, inclusion: {in: [true, false],
                                   message: 'must be true or false'}
  #No questions in one application template with the same number
  validates :number, uniqueness: {scope: :application_template}
  validates :name, length: {maximum: 20}

  default_scope { order :number }
  #Within a particular application template, moves a question up or down.
  #Accepts the symbol :up or the symbol :down as arguments.
  def move(direction)
    #binding.pry
    case direction
    when :up
      other_number = number - 1
    when :down
      other_number = number + 1
    end
    other_question = application_template.questions.where(number: other_number).first
    if other_question.present?
      ActiveRecord::Base.transaction do
        other_question.number = self.number
        self.number = other_number
        self.save(validate: false)
        other_question.save(validate: false)
        #Since we skipped validations in order to save, re-run validations. If either
        #question fails, raise an exception, which will rollback the transaction.
        #The exception does not percolate further up the stack, so we don't need to
        #handle it elsewhere or raise any specific exception.
        raise unless self.valid? && other_question.valid?
      end
    end
  end

end
