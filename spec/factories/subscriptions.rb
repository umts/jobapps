# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    user
    position
    sequence(:email) { |n| "email#{n}@example.com" }
  end
end
