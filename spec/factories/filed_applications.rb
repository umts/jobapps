FactoryGirl.define do
  factory :filed_application do
    user
    position
    data [%w('prompt_1' 'Do you like cats'), %w('response_1 No')]
    reviewed false
  end

  trait :with_unavailability do
    after :create do |application|
      create :unavailability, filed_application: application
    end
  end
end
