# frozen_string_literal: true

FactoryGirl.define do
  factory :position do
    department
    name 'Position'
    default_interview_location 'Place'
  end
end
