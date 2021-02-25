# frozen_string_literal: true

class UnavailabilityParser
  def initialize(data)
    @data = data
    @unavailability = blank_unavailability
    @processing_complete = false
  end

  def process!
    @unavailability = blank_unavailability
    true_values.each_key do |day_and_time|
      day, _, time = day_and_time.partition('_')
      @unavailability[day.to_sym].push time
    end
    @processing_complete = true
    @unavailability
  end

  def result
    process! unless @processing_complete
    @unavailability
  end

  private

  def blank_unavailability
    Hash.new { |k, v| k[v] = [] }
  end

  def true_values
    @data.select { |_, value| value == '1' }
  end
end
