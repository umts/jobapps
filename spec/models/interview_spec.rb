require 'rails_helper'
include DateAndTimeMethods

describe Interview do
  describe 'callbacks' do
    it 'sends interview confirmation mailer when interview is created' do
      # expect the mailer method to be called
      expect(JobappsMailer).to receive :interview_confirmation
      create :interview
    end
    context 'interview reschedule mailer method' do
      before :each do
        @interview = create :interview
      end
      it 'sends when location changes' do
        expect(JobappsMailer).to receive :interview_reschedule
        @interview.update location: 'another location'
      end
      it 'sends when scheduled changes' do
        expect(JobappsMailer).to receive :interview_reschedule
        @interview.update scheduled: 1.day.since.to_datetime
      end
      it 'does not send if completed changes' do
        expect(JobappsMailer).not_to receive :interview_reschedule
        @interview.toggle :completed
      end
    end
  end

  describe 'calendar_title' do
    before :each do
      @interview = create :interview, location: 'Anywhere'
    end
    it 'is titleized (starts with a capital letter)' do
      expect(@interview.calendar_title).to match(/^[[:upper:]]/)
    end
    it 'includes the name of interviewee' do
      interviewee = @interview.user
      expect(@interview.calendar_title).to include interviewee.first_name
      expect(@interview.calendar_title).to include interviewee.last_name
    end
  end

  describe 'information' do
    before :each do
      @interview = create :interview
    end
    it 'includes the formatted date and time' do
      expect(@interview.information)
        .to include format_date_time(@interview.scheduled)
    end
    it 'includes the location' do
      expect(@interview.information).to include @interview.location
    end
    it 'includes the name of interviewee if so requested' do
      user = @interview.user
      expect(@interview.information include_name: true)
        .to include user.first_name
      expect(@interview.information include_name: true)
        .to include user.last_name
    end
  end

  describe 'pending?' do
    it 'returns true if interview has not been completed' do
      interview = create :interview, completed: false
      expect(interview.pending?).to be true
    end
    it 'returns false if interview has been completed' do
      interview = create :interview, completed: true
      expect(interview.pending?).to be false
    end
  end
end
