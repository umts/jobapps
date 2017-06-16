# frozen_string_literal: true

FactoryGirl.define do
  factory :application_submission do
    user
    position
    data [['prompt_1', 'Do you like cats'], %w[response_1 No]]
    reviewed false
  end

  trait :with_unavailability do
    after :create do |application|
      create :unavailability, application_submission: application
    end
  end
end
