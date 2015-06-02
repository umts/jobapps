require 'rails_helper'
include DateAndTimeMethods

describe DateAndTimeMethods do
  before :each do
    @datetime = DateTime.now
    Timecop.freeze @datetime
  end
  describe 'format_date_time' do
    context 'format given'  do
      context 'iCal format' do
        it 'renders the time in iCal format' do
          expect(format_date_time @datetime, format: :iCal).to eql @datetime.utc.strftime('%Y%m%dT%H%M%SZ')
        end
      end
    end
    context 'no format given' do
      it 'renders the default format' do
        expect(format_date_time @datetime).to eql @datetime.strftime('%A, %B %e, %Y - %l:%M %P')
      end
    end
  end
  after :each do
    Timecop.return
  end
end
