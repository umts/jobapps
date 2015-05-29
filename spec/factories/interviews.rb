FactoryGirl.define do
  factory :interview do
    association :application_record
    association :user
    completed false
    hired false
    location 'Location'
    scheduled DateTime.now
  end
end
