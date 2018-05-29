# frozen_string_literal: true

FactoryBot.define do
  factory :site_text do
    sequence(:name) { |n| "Name #{n}" }
    text 'text'
  end
end
