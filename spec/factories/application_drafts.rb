# frozen_string_literal: true

FactoryGirl.define do
  factory :application_draft do
    application_template
    user
  end
end
