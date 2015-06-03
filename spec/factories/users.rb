FactoryGirl.define do
  factory :user do
    email      'person@example.com'
    first_name 'FirstName'
    last_name  'LastName'
    staff      false
    sequence(:spire) { |n| n.to_s.rjust 8, '0' }
  end
end
