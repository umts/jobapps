# frozen_string_literal: true

require 'rails_helper'

describe ApplicationSubmissionHelper do
  describe 'format_response' do
    it 'is a blanks string for blank responses' do
      expect(format_response(nil, 'anything')).to eq('')
    end

    it 'formats dates' do
      expect(format_response('2020-01-02', 'date')).to eq('01/02/2020')
    end

    it 'returns the input for all other types' do
      string = Array.new(20) { ('a'..'z').to_a.sample }.join
      expect(format_response(string, 'whatever')).to eq(string)
    end
  end
end
