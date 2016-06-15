FactoryGirl.define do
  factory :user do
    email      'person@example.com'
    first_name 'FirstName'
    last_name  'LastName'
    staff      false
    sequence(:spire) { |n| n.to_s.rjust 8, '0' }

    trait :staff do
      staff true
    end
    trait :student do
      staff false
    end
    trait :admin do 
      admin true
      staff true
    end
  end
end
