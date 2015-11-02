FactoryGirl.define do
  factory :application_record do
    user
    position
    responses [%w('prompt_1' 'Do you like cats'), %w('response_1 No')]
    reviewed false
  end
end
