# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    user
    position
    email { 'email@example.com' }
  end
end
