require 'rails_helper'
include DateAndTimeMethods

describe 'viewing job applications individually' do
  context 'there are no pending applications or interviews' do
    let!(:position) { create :position }
    # There must be a position for which there exist
    # neither applications nor interviews.
    before :each do
      when_current_user_is :staff, integration: true
      visit staff_dashboard_url
    end
    it 'lets the user know there are no pending applications' do
      expect(page).to have_text 'No pending applications'
    end
    it 'lets the user know there are no pending interviews' do
      expect(page).to have_text 'No pending interviews'
    end
  end
  context 'there are pending applications and interviews' do
    let!(:unreviewed_record) { create :application_submission, reviewed: false }
    let!(:reviewed_record) { create :application_submission, reviewed: true }
    let!(:interview) do
      create :interview,
             application_submission: reviewed_record
    end
    before :each do
      when_current_user_is :staff, integration: true
      visit staff_dashboard_url
    end
    it 'provides a means to reject the application and provide a staff note' do
      click_link unreviewed_record.user.proper_name,
                 href: application_submission_path(unreviewed_record)
      fill_in 'staff_note', with: 'note'
      click_button 'Review application without scheduling interview'
      expect(page.current_url).to eql staff_dashboard_url
      expect(page).to have_text 'Application has been marked as reviewed'
    end
    it 'provides a means to accept the application and schedule an interview' do
      click_link unreviewed_record.user.proper_name,
                 href: application_submission_path(unreviewed_record)
      fill_in 'interview[scheduled]', with: 1.week.since
      fill_in 'interview[location]', with: 'A Place'
      click_button 'Review application and schedule interview'
      expect(page.current_url).to eql staff_dashboard_url
      expect(page).to have_text 'Application has been marked as reviewed'
    end
    it 'provides a means to reschedule the interview' do
      click_link reviewed_record.interview.information(include_name: true)
      expect(page).to have_text 'Interview is scheduled for: ' +
                                format_date_time(interview.scheduled)
      Timecop.freeze do
        fill_in 'scheduled', with: 1.week.since
        click_button 'Reschedule interview'
        expect(interview.reload.scheduled.to_datetime)
          .to be_within(1.second).of(1.week.since.to_datetime)
      end
      expect(page.current_url).to eql staff_dashboard_url
      expect(page).to have_text 'Interview has been rescheduled'
    end
    it 'provides a means to mark interview complete and candidate hired' do
      click_link reviewed_record.user.proper_name,
                 href: application_submission_path(reviewed_record)
      click_button 'Candidate hired'
      expect(page).to have_text 'Interview marked as completed'
      path = application_submission_path(reviewed_record)
      expect page.has_no_link? reviewed_record.user.proper_name,
                               href: path
    end
    it 'provides a means to mark interview complete and candidate not hired' do
      click_link reviewed_record.user.proper_name,
                 href: application_submission_path(reviewed_record)
      fill_in 'interview_note', with: 'reason for rejection'
      click_button 'Candidate not hired'
      expect(page).to have_text 'Interview marked as completed'
      path = application_submission_path(reviewed_record)
      expect page.has_no_link? reviewed_record.user.proper_name,
                               href: path
    end
  end
end
