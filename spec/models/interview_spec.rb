require 'rails_helper'
include DateAndTimeMethods

describe Interview do
  describe 'create hooks' do
    it 'sends an email when not in test' do
      expect(Rails.env).to receive(:test?).and_return false
      # need to specify configuration value
      allow(CONFIG).to receive(:[]).with(:email)
        .and_return default_from: 'test@example.com'
      # expect the mailer method to be called
      expect(JobappsMailer).to receive(:interview_confirmation)
      create :interview
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
    it 'includes the name of interviewee' do
      user = @interview.user
      expect(@interview.information).to include user.first_name
      expect(@interview.information).to include user.last_name
    end
  end

  describe 'pending?' do
    it 'returns true if interview has not been completed' do
      interview = create :interview, completed: false
      expect(interview.pending?).to eql true
    end
    it 'returns false if interview has been completed' do
      interview = create :interview, completed: true
      expect(interview.pending?).to eql false
    end
  end
end
