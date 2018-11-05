# frozen_string_literal: true

FactoryBot.define do
  factory :interview do
    application_submission
    user
    completed { false }
    hired { false }
    location { 'Location' }
    scheduled { Time.zone.now }
  end
end
