FactoryGirl.define do
  factory :application_record do
    user
    position
    responses question: :answer
    reviewed false
  end
end
