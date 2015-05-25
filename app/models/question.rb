class Question < ActiveRecord::Base
  belongs_to :application_template

  DATA_TYPES = %w(text
                  number
                  yes/no
                  date
                  heading)

  validates :application_template,
            :data_type,
            :number,
            :prompt,
            presence: true
  #Headings don't require a name, just text
  validates :name, presence: true, unless: ->{data_type == 'heading'}
  validates :required, inclusion: {in: [true, false],
                                   message: 'must be true or false'}
  #No questions in one application template with the same number or the same name-
  #allow blank names for headings
  validates :name, :number, uniqueness: {scope: :application_template, allow_blank: true}
  validates :name, length: {maximum: 20}

  default_scope { order :number }

  def date?
    data_type == 'date'
  end

  def heading?
    data_type == 'heading'
  end

  #Within a particular application template, moves a question up or down.
  #Accepts the symbol :up or the symbol :down as arguments.
  def move direction
    #binding.pry
    case direction
    when :up
      other_number = self.number - 1
    when :down
      other_number = self.number + 1
    end
    other_question = application_template.questions.where(number: other_number).first
    if other_question.present?
      ActiveRecord::Base.transaction do
        other_question.number = self.number
        self.number = other_number
        self.save validate: false
        other_question.save
        #Since we skipped validations in order to save, re-run validations.
        #If the question fails, raise an exception.
        #The exception does not propagate further up the stack, so we don't need to
        #handle it elsewhere or raise any specific exception.
        raise unless self.valid?
      end
    end
  end

end
