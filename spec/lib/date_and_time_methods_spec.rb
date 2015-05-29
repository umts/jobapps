require 'rails_helper'
include DateAndTimeMethods

describe DateAndTimeMethods do
  describe 'format_date_time' do
    before :each do
      @datetime = DateTime.now
    end
    context 'no format specified' do
      it 'returns something' do
        expect(format_date_time @datetime).not_to be_empty
      end
    end
    context 'iCal format specified' do
      it 'returns iCal formatted times in UTC' do
        expect(format_date_time @datetime, format: :iCal)
          .to eql @datetime.utc.strftime('%Y%m%dT%H%M%SZ')
      end
    end
  end
end
