# frozen_string_literal: true

FactoryBot.define do
  factory :position do
    department
    name 'Position'
    default_interview_location 'Place'
  end
end
