FactoryGirl.define do
  factory :question do
    association :application_template
    data_type   'text'
    sequence    :number
    prompt      'Question prompt'
    required    true
    sequence(:name) { |n| "Question name #{n}" }
  end
end
