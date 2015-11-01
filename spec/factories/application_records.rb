FactoryGirl.define do
  factory :application_record do
    user
    position
    responses [%w(response_1 No), ['prompt_1', 'Do you like cats']]
    reviewed false
  end
end
