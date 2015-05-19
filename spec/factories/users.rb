FactoryGirl.define do
  factory :user do
    first_name 'FirstName'
    last_name  'LastName'
    staff      false
    sequence(:spire){|n| n.to_s.rjust 8, '0'}
  end
end
