require 'rails_helper'

describe JobappsMailer do
  describe 'interview_confirmation' do
    before :each do
      @interview = create :interview
      @user = @interview.user
      @from = 'test@example.com'
      # Stub out the configuration value
      expect_any_instance_of(ApplicationConfiguration)
        .to receive(:configured_value)
        .with([:email, :default_from], anything)
        .and_return(@from)
    end
    let :output do
      JobappsMailer.interview_confirmation(@interview)
    end
    it 'emails from the configured value' do
      expect(output.from).to eql Array(@from)
    end
    it 'emails to the interviewee' do
      expect(output.to).to eql Array(@user.email)
    end
    it 'has a subject of interview confirmation' do
      expect(output.subject).to eql 'Interview Confirmation'
    end
    it 'includes the date and time of the interview' do
      expect(output.body.encoded).to include @interview.scheduled.to_s
    end
  end
end
