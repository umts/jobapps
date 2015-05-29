require 'rails_helper'

describe ApplicationRecord do
  describe 'pending?' do
    it 'returns true if record has not been reviewed' do
      record = create :application_record, reviewed: false
      expect(record.pending?).to eql true
    end
    it 'returns false if record has been reviewed' do
      record = create :application_record, reviewed: true
      expect(record.pending?).to eql false
    end
  end
end
