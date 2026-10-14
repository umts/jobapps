# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'person@example.com' }
    first_name { 'FirstName' }
    last_name { 'LastName' }
    sequence(:entra_uid) { |n| "entra-uid-#{n}" }

    trait :manager do
      transient do
        managing { [association(:position)] }
      end

      email { 'manager@umass.edu' }

      after :create do |user, context|
        Array(context.managing).each { |position| create(:position_manager, user:, position:) }
      end
    end

    trait :admin do
      admin { true }
    end
  end
end
