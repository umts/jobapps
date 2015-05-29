FactoryGirl.define do
  factory :position do
    association :department
    name 'Position'
  end
end
