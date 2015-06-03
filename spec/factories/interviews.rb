FactoryGirl.define do
  factory :interview do
    application_record
    user
    completed false
    hired false
    location 'Location'
    scheduled DateTime.now
  end
end
