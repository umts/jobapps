# frozen_string_literal: true

FactoryBot.define do
  factory :application_draft do
    application_template
    association :locked_by, factory: :user
  end
end
