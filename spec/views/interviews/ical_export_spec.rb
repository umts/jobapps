# frozen_string_literal: true

require 'rails_helper'

describe 'interviews/interview.ics.erb' do
  before :each do
    @interview = create :interview
  end

  it 'Passes the correct field properties to the ics object' do
    render
    lines = {}
    rendered.each_line do |line|
      key, value = line.split ':', 2
      lines[key] = value.strip
    end
    expect(lines.fetch 'DTSTART')
      .to eql @interview.scheduled.to_formatted_s :ical
    expect(lines.fetch 'DESCRIPTION')
      .to eql application_submission_url(@interview.application_submission)
    expect(lines.fetch 'SUMMARY').to eql @interview.calendar_title
    expect(lines.fetch 'UID')
      .to eql "INTERVIEW#{@interview.id}@UMASS_TRANSIT//JOBAPPS"
    expect(lines.fetch 'DTSTAMP')
      .to eql Time.zone.now.to_formatted_s :ical
  end
end
