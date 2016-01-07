require 'rails_helper'
include RSpecHtmlMatchers

describe 'interviews/interview.ics.erb' do
  before :each do
    @interview = create :interview
  end
  
  it 'Passes the correct field properties to the ics object' do
    render
    @lines = {}
    rendered.each_line do |line|
      key, value = line.split ':', 2
      @lines[key] = value.strip
    end
    @lines.each do |key, value|
    end
    expect(@lines['DTSTART']).to eql (format_date_time @interview.scheduled, format: :iCal)
    expect(@lines['DESCRIPTION']).to eql application_record_url(@interview.application_record_id)
    expect(@lines['SUMMARY']).to eql @interview.calendar_title
    expect(@lines['UID']).to eql 'INTERVIEW' + @interview.id.to_s + "@UMASS_TRANSIT//JOBAPPS"
    expect(@lines['DTSTAMP']).to eql (format_date_time DateTime.now, format: :iCal)
  end
end