# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { 'person@example.com' }
    first_name { 'FirstName' }
    last_name { 'LastName' }
    staff { false }
    sequence(:entra_uid) { |n| "entra-uid-#{n}" }

    trait :staff do
      staff { true }
      email { 'staff@umass.edu' }
    end

    trait :student do
      staff { false }
    end

    trait :admin do
      staff
      admin { true }
    end
  end
end
