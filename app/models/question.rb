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

  #Within a particular application template, moves a question up or down.
  #Accepts the symbol :up or the symbol :down as arguments.
  def move(direction)
  end
end
