FactoryGirl.define do
  factory :unavailability do
    application_record
    sunday []
    monday %w(10AM 11AM 12PM)
    tuesday %w(11AM 12PM 1PM 2PM 3PM 4PM 5PM)
    wednesday %w(10AM 11AM 12PM)
    thursday %w(11AM 12PM 1PM 2PM 3PM 4PM 5PM)
    friday %w(10AM 11AM 12PM)
    saturday []
  end
end
