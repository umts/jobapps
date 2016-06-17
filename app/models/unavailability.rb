class Unavailability < ActiveRecord::Base
  belongs_to :application_record

  HOURS = %w(7AM 8AM 9AM 10AM 11AM 12PM 1PM 2PM 3PM 4PM 5PM 6PM 7PM 8PM).freeze

  # this will serialize the columns of the unavailability model
  # so that they accept strings in the form of arrays
  Date::DAYNAMES.map(&:downcase).map(&:to_sym).each { |d| serialize d, Array }
end
