# frozen_string_literal: true

FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "Name #{n}" }
  end
end
