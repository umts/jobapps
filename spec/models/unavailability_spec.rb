# frozen_string_literal: true

require 'rails_helper'

describe Unavailability do
  let :unavailability do
    build(:unavailability, sunday: [],
                           monday: %w[10AM 11AM 12PM],
                           tuesday: %w[11AM 12PM 1PM 2PM 3PM 4PM 5PM],
                           wednesday: %w[10AM 11AM 12PM],
                           thursday: %w[11AM 12PM 1PM 2PM 3PM 4PM 5PM],
                           friday: %w[10AM 11AM 12PM],
                           saturday: [])
  end

  describe '#grid' do
    subject(:call) { unavailability.grid }

    it 'gives false for available times' do
      expect(call[0][0]).to be false
    end

    it 'gives true for unavailable times' do
      expect(call[1][3]).to be true
    end
  end
end
