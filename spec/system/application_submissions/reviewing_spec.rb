# frozen_string_literal: true

require 'rails_helper'

describe 'reviewing applications' do
  let!(:unreviewed_record) { create(:application_submission, reviewed: false) }
  let!(:reviewed_record) { create(:application_submission, reviewed: true) }
  let!(:interview) { create(:interview, application_submission: reviewed_record) }

  let :mail do
    ActionMailer::MessageDelivery.new(JobappsMailer, :application_denial)
  end

  before do
    when_current_user_is :staff
    visit staff_dashboard_path
  end

  it 'provides a means to reject the application without a staff note' do
    click_link unreviewed_record.user.proper_name,
               href: application_submission_path(unreviewed_record)
    click_button 'Decline'
    expect(page.current_path).to eql staff_dashboard_path
    expect(page).to have_text 'Application has been marked as reviewed'
  end

  it 'provides a means to notify the applicant of denial' do
    click_link unreviewed_record.user.proper_name,
               href: application_submission_path(unreviewed_record)
    expect(JobappsMailer).to receive(:application_denial)
      .with(unreviewed_record)
      .and_return mail
    expect(mail).to receive(:deliver_now).and_return true
    page.check 'Notify applicant of denial'
    page.fill_in 'Tell them why',
                 with: "It's not you, it's me"
    page.fill_in 'Staff note',
                 with: "They said they don't like Star Trek"
    click_button 'Decline'
    expect(unreviewed_record.reload.staff_note)
      .to eq "They said they don't like Star Trek"
    expect(unreviewed_record).to be_reviewed
    expect(unreviewed_record).not_to be_saved_for_later
  end

  it 'provides a means to reject without notifying' do
    click_link unreviewed_record.user.proper_name,
               href: application_submission_path(unreviewed_record)
    expect(JobappsMailer).not_to receive(:application_denial)
    page.fill_in 'Staff note',
                 with: "They said they don't like Star Trek"
    # the box is checked by default
    uncheck 'Notify applicant of denial'
    click_button 'Decline'
    expect(unreviewed_record.reload.staff_note)
      .to eq "They said they don't like Star Trek"
    expect(unreviewed_record).to be_reviewed
    expect(unreviewed_record).not_to be_saved_for_later
  end

  it 'provides a means to accept the application and schedule an interview' do
    click_link unreviewed_record.user.proper_name,
               href: application_submission_path(unreviewed_record)
    fill_in 'Date/time', with: 1.week.since
    fill_in 'Location', with: 'A Place'
    click_button 'Approve'
    expect(page.current_path).to eql staff_dashboard_path
    expect(page).to have_text 'Application has been marked as reviewed'
    expect(unreviewed_record.interview.reload.scheduled.to_datetime)
      .to be_within(1.second).of(1.week.since.to_datetime)
  end

  it 'provides a means to reschedule the interview' do
    time = interview.scheduled.to_fs :long_with_time
    click_link reviewed_record.interview.information(include_name: true)
    expect(page).to have_text "Interview is scheduled for: #{time}"
    Timecop.freeze do
      fill_in 'scheduled', with: 1.week.since
      click_button 'Reschedule interview'
      expect(interview.reload.scheduled.to_datetime)
        .to be_within(1.second).of(1.week.since.to_datetime)
    end
    expect(page.current_path).to eql staff_dashboard_path
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
