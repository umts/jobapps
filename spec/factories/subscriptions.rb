FactoryGirl.define do
  factory :subscription do
    user
    position
    email 'email@example.com'
  end
end
