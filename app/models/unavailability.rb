# frozen_string_literal: true

class Unavailability < ApplicationRecord
  belongs_to :application_submission

  HOURS = %w[7AM 8AM 9AM 10AM 11AM 12PM 1PM 2PM 3PM 4PM 5PM 6PM 7PM 8PM].freeze

  # this will serialize the columns of the unavailability model
  # so that they accept strings in the form of arrays
  Date::DAYNAMES.map(&:downcase).map(&:to_sym).each { |d| serialize d, type: Array }

  # the grid method returns a data structure
  # which represents the unavailability as a 2d array
  # of booleans, i.e, if Sunday has unavailable times
  # at 7AM and 8AM, then grid[0][0] and grid[0][1]
  # will be true, and grid[0][2...14] will be false,
  # because the applicant is available during those times.

  def grid
    Date::DAYNAMES.map do |name|
      daily_hours = send(name.downcase)
      HOURS.map do |hour|
        daily_hours.include? hour
      end
    end
  end
end
