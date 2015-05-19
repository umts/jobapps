class ResponseField < ActiveRecord::Base
  belongs_to :application_template

  DATA_TYPES = %w(text
                  number
                  yes/no)

  validates :application_template,
            :data_type,
            :name,
            :number,
            :prompt,
            presence: true
  validates :required, inclusion: {in: [true, false]}
  #No questions in one application template with the same number
  validates :number, uniqueness: {scope: :application_template}
end
