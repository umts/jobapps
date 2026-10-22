# frozen_string_literal: true

FactoryBot.define do
  factory :position do
    department
    sequence(:name) { |n| "Position #{n}" }
    default_interview_location { 'Place' }
  end
end
