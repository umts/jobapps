FactoryGirl.define do
  factory :question do
    association :application_template
    data_type   'text'
    name        'Question name'
    #Number must be unique
    sequence    :number
    prompt      'Question prompt'
    required    true
  end
end
