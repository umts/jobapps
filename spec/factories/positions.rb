# frozen_string_literal: true

FactoryBot.define do
  factory :position do
    sequence(:name) { |n| "Position #{n}" }
    default_interview_location { 'Place' }
  end
end
