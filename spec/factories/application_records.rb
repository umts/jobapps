FactoryGirl.define do
  factory :application_record do
    association :user
    association :position
    responses question: :answer
    reviewed false
  end
end
