# frozen_string_literal: true

FactoryGirl.define do
  factory :department do
    sequence(:name) { |n| "Name #{n}" }
  end
end
