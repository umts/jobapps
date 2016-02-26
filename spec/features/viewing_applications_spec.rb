require 'rails_helper'
include DateAndTimeMethods

describe 'viewing job applications individually' do
  context 'there are no pending applications or interviews' do
    before :each do
      when_current_user_is :staff, integration: true
      visit staff_dashboard_url
    end
    it 'lets the user know there are no pending applications' do
      expect page.has_text? 'No pending applications'
    end
    it 'lets the user know there are no pending interviews' do
      expect page.has_text? 'No pending interviews'
    end
  end
  context 'there are pending applications and interviews' do
    let!(:unreviewed_record) { create :application_record, reviewed: false }
    let!(:reviewed_record) { create :application_record, reviewed: true }
    let!(:interview) do
      create :interview,
             application_record: reviewed_record,
             scheduled: Time.zone.today
    end
    before :each do
      when_current_user_is :staff, integration: true
      visit staff_dashboard_url
    end
    it 'provides a means to reject the application and provide a staff note' do
      click_link unreviewed_record.user.proper_name.to_s,
                 href: application_record_path(unreviewed_record)
      fill_in 'staff_note', with: 'note'
      click_button 'Review application without scheduling interview'
      expect(page.current_url).to eql staff_dashboard_url
      expect page.has_text? 'Application has been marked as reviewed'
    end
    it 'provides a means to accept the application and schedule an interview' do
      click_link unreviewed_record.user.proper_name.to_s,
                 href: application_record_path(unreviewed_record)
      fill_in 'interview[scheduled]', with: 1.week.since
      fill_in 'interview[location]', with: 'A Place'
      click_button 'Review application and schedule interview'
      expect(page.current_url).to eql staff_dashboard_url
      expect page.has_text? 'Application has been marked as reviewed'
    end
    it 'provides a means to reschedule the interview' do
      scheduled_time = format_date_time reviewed_record.interview.scheduled
      location = reviewed_record.interview.location
      user = reviewed_record.user.proper_name
      click_link "#{scheduled_time} at #{location}: #{user}",
                 href: application_record_path(reviewed_record)
      expect page.has_text? "Interview is scheduled for:
        #{format_date_time interview.scheduled}"
      fill_in 'scheduled', with: 1.week.since
      click_button 'Reschedule interview'
      expect(page.current_url).to eql staff_dashboard_url
      expect page.has_text? 'Interview has been rescheduled'
    end
    it 'provides a means to mark interview complete and candidate hired' do
      click_link reviewed_record.user.proper_name.to_s,
                 href: application_record_path(reviewed_record)
      click_button 'Candidate hired'
      expect page.has_text? 'Interview marked as completed'
      expect page.has_no_link? reviewed_record.user.proper_name.to_s,
                               href: application_record_path(reviewed_record)
    end
    it 'provides a means to mark interview complete and candidate not hired' do
      click_link reviewed_record.user.proper_name.to_s,
                 href: application_record_path(reviewed_record)
      fill_in 'interview_note', with: 'reason for rejection'
      click_button 'Candidate not hired'
      expect page.has_text? 'Interview marked as completed'
      expect page.has_no_link? reviewed_record.user.proper_name.to_s,
                               href: application_record_path(reviewed_record)
    end
  end
end
