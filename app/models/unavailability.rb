class Unavailability < ActiveRecord::Base
  belongs_to :application_record

  HOURS = ['7AM','8AM','9AM','10AM', '11AM', '12PM', '1PM','2PM','3PM','4PM','5PM','6PM','7PM','8PM']
  DAYS = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']

  DAYS.map(&:downcase).map(&:to_sym).each{ |d| serialize d, Array }

end
