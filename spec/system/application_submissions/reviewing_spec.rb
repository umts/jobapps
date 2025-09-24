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

  describe 'pending applications' do
    before do
      allow(JobappsMailer).to receive(:application_denial).and_return(mail)
      allow(mail).to receive(:deliver_now).and_return(true)
      click_link unreviewed_record.user.proper_name
    end

    it 'redirects to the staff dashboard on declining an interview' do
      click_button 'Decline'
      expect(page).to have_current_path(staff_dashboard_path)
    end

    it 'informs the user that the applcation is reviewed when declining an interview' do
      click_button 'Decline'
      expect(page).to have_text('Application has been marked as reviewed')
    end

    context 'when requesting denial notification' do
      before do
        check 'Notify applicant of denial'
        fill_in 'Tell them why', with: "It's not you, it's me"
        fill_in 'Staff note', with: "They said they don't like Star Trek"
        click_button 'Decline'
      end

      it 'creates a notification email' do
        expect(JobappsMailer).to have_received(:application_denial).with(unreviewed_record)
      end

      it 'sends the notification email' do
        expect(mail).to have_received(:deliver_now)
      end

      it 'saves the staff note' do
        expect(unreviewed_record.reload.staff_note).to eq("They said they don't like Star Trek")
      end

      it 'marks the application as reviewed' do
        expect(unreviewed_record.reload).to be_reviewed
      end

      it 'ensures the application is not marked as saved for later' do
        expect(unreviewed_record.reload).not_to be_saved_for_later
      end
    end

    context 'when declining without notification' do
      before do
        fill_in 'Staff note', with: "They said they don't like Star Trek"
        uncheck 'Notify applicant of denial'
        click_button 'Decline'
      end

      it 'does not create a notification email' do
        expect(JobappsMailer).not_to have_received(:application_denial)
      end

      it 'saves the staff note' do
        expect(unreviewed_record.reload.staff_note).to eq("They said they don't like Star Trek")
      end

      it 'marks the application as reviewed' do
        expect(unreviewed_record.reload).to be_reviewed
      end

      it 'ensures the application is not marked as saved for later' do
        expect(unreviewed_record.reload).not_to be_saved_for_later
      end
    end

    context 'when accepting the application and scheduling an interview' do
      before do
        fill_in 'Date/time', with: 1.week.from_now
        fill_in 'Location', with: 'A Place'
        click_button 'Approve'
      end

      it 'redirects to the staff dashboard' do
        expect(page).to have_current_path(staff_dashboard_path)
      end

      it 'informs the user that the application is reviewed' do
        expect(page).to have_text('Application has been marked as reviewed')
      end

      it 'schedules the interview' do
        expect(unreviewed_record.interview.reload.scheduled.to_datetime)
          .to be_within(1.second).of(1.week.from_now.to_datetime)
      end
    end
  end

  describe 'scheduled interviews' do
    context 'when rescheduling the interview' do
      before do
        click_link interview.information(include_name: true)
        fill_in 'scheduled', with: 1.week.from_now
      end

      it 'shows the current interview time' do
        time = interview.scheduled.to_fs :long_with_time
        expect(page).to have_text "Interview is scheduled for: #{time}"
      end

      it 'changes the interview time' do
        click_button 'Reschedule interview'
        expect(interview.reload.scheduled.to_datetime).to be_within(30.seconds).of(1.week.from_now.to_datetime)
      end

      it 'redirects to the staff dashboard' do
        click_button 'Reschedule interview'
        expect(page).to have_current_path(staff_dashboard_path)
      end

      it 'informs the user of the rescheduling' do
        click_button 'Reschedule interview'
        expect(page).to have_text('Interview has been rescheduled')
      end
    end

    context 'when hiring the interviewee' do
      before do
        click_link interview.information(include_name: true)
        click_button 'Candidate hired'
      end

      it 'informs the user that the interview is complete' do
        expect(page).to have_text('Interview marked as completed')
      end

      it 'does not show the hired interviewee on the dashboard' do
        expect(page).to have_no_link(interview.information(include_name: true))
      end
    end

    context 'when not hiring the interviewee' do
      before do
        click_link interview.information(include_name: true)
        fill_in 'interview_note', with: 'reason for rejection'
        click_button 'Candidate not hired'
      end

      it 'informs the user that the interview is complete' do
        expect(page).to have_text('Interview marked as completed')
      end

      it 'does not show the hired interviewee on the dashboard' do
        expect(page).to have_no_link(interview.information(include_name: true))
      end
    end
  end
end
