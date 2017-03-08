FactoryGirl.define do
  factory :interview do
    filed_application
    user
    completed false
    hired false
    location 'Location'
    scheduled Time.zone.now
  end
end
