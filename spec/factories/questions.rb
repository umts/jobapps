FactoryGirl.define do
  factory :question do
    application_template
    data_type   'text'
    sequence    :number
    prompt      'Question prompt'
    required    true
  end
end
