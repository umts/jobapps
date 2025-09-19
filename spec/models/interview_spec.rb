# frozen_string_literal: true

require 'rails_helper'

describe Interview do
  describe 'send_confirmation callback' do
    let(:mail) { ActionMailer::MessageDelivery.new(JobappsMailer, :interview_confirmation) }

    before do
      allow(JobappsMailer).to receive(:interview_confirmation).and_return(mail)
      allow(mail).to receive(:deliver_now).and_return(true)
    end

    it 'creates the interview confirmation mail when interview is created' do
      create(:interview)
      expect(JobappsMailer).to have_received(:interview_confirmation)
    end

    it 'sends the interview confirmation when interview is created' do
      create(:interview)
      expect(mail).to have_received(:deliver_now)
    end
  end

  describe 'resend_confirmation callback' do
    let(:mail) { ActionMailer::MessageDelivery.new(JobappsMailer, :interview_reschedule) }
    let(:interview) { create(:interview) }

    before do
      allow(JobappsMailer).to receive(:interview_reschedule).and_return(mail)
      allow(mail).to receive(:deliver_now).and_return(true)
    end

    it 'creates the reschedule email when the location changes' do
      interview.update location: 'another location'
      expect(JobappsMailer).to have_received(:interview_reschedule)
    end

    it 'sends the resceduled email when the location changes' do
      interview.update location: 'another location'
      expect(mail).to have_received(:deliver_now)
    end

    it 'creates the rescheduled email when the scheduled time changes' do
      interview.update scheduled: 1.day.from_now.to_datetime
      expect(JobappsMailer).to have_received(:interview_reschedule)
    end

    it 'sends the rescheduled email when the scheduled time changes' do
      interview.update scheduled: 1.day.from_now.to_datetime
      expect(mail).to have_received(:deliver_now)
    end

    it 'does not send anything if completed changes' do
      interview.toggle :completed
      expect(JobappsMailer).not_to have_received(:interview_reschedule)
    end
  end

  describe '#calendar_title' do
    let(:interview) { build(:interview, location: 'Anywhere') }

    it 'is titleized (starts with a capital letter)' do
      expect(interview.calendar_title).to match(/^[[:upper:]]/)
    end

    it 'includes the name of interviewee' do
      interviewee = interview.user
      expect(interview.calendar_title).to include(interviewee.first_name, interviewee.last_name)
    end
  end

  describe '#information' do
    let(:interview) { build(:interview) }

    it 'includes the formatted date and time' do
      expect(interview.information).to include interview.scheduled.to_fs(:long_with_time)
    end

    it 'includes the location' do
      expect(interview.information).to include interview.location
    end

    it 'includes the name of interviewee if so requested' do
      user = interview.user
      expect(interview.information include_name: true).to include(user.first_name, user.last_name)
    end
  end

  describe '#pending?' do
    it 'returns true if interview has not been completed' do
      interview = build(:interview, completed: false)
      expect(interview).to be_pending
    end

    it 'returns false if interview has been completed' do
      interview = create(:interview, completed: true)
      expect(interview).not_to be_pending
    end
  end
end
