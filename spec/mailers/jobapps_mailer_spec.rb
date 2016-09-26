require 'rails_helper'
include ApplicationConfiguration

describe JobappsMailer do
  before :each do
    @from = configured_value [:email, :default_from]
  end

  describe 'application denial' do
    before :each do
      position = create :position
      @template = create :application_template,
                         position: position, email: 'steve@sharklazers.com'
      @application_record = create :application_record, staff_note: 'note',
                                                        position: position
      @user = @application_record.user
    end
    let :output do
      JobappsMailer.application_denial @application_record
    end
    it 'emails from the configured value' do
      expect(output.from).to eql Array(@from)
    end
    it 'emails to the applicant' do
      expect(output.to).to eql Array(@user.email)
    end
    it 'has a subject of application denial' do
      expect(output.subject).to eql 'Application Denial'
    end
    it 'has the correct reply-to' do
      expect(output.reply_to).to eql Array(@template.email)
    end
    context 'notify_of_reason is set to true' do
      before :each do
        # Allow generic invocation
        allow_any_instance_of(ApplicationConfiguration)
          .to receive :configured_value
        # Stub the invocation we expect
        allow_any_instance_of(ApplicationConfiguration)
          .to receive(:configured_value)
          .with([:on_application_denial, :notify_of_reason], anything)
          .and_return true
      end
      it 'includes a reason for application denial' do
        expect(output.body.encoded)
          .to include @application_record.staff_note
      end
    end
    context 'notify_of_reason is set to false' do
      before :each do
        # Allow generic invocation
        allow_any_instance_of(ApplicationConfiguration)
          .to receive :configured_value
        # Stub the invocation we expect
        allow_any_instance_of(ApplicationConfiguration)
          .to receive(:configured_value)
          .with([:on_application_denial, :notify_of_reason], anything)
          .and_return false
      end
      it 'does not include a reason for application denial' do
        expect(output.body.encoded)
          .not_to include @application_record.staff_note
      end
    end
  end

  describe 'application_notification' do
    let(:position) { create :position }
    let(:subscription) { create :subscription, position: position }
    let(:applicant) { create :user, :student }
    let :output do
      JobappsMailer.application_notification subscription, position, applicant
    end
    it 'emails from the configured value' do
      expect(output.from).to eql Array(@from)
    end
    it 'emails to the subscriber email' do
      expect(output.to).to eql Array(subscription.email)
    end
    it 'has a subject notifying the subscriber of the message purpose' do
      expect(output.subject).to eql "New application for #{position.name}"
    end
    it 'includes the position name and the name of the applicant' do
      expect(output.body).to include position.name, applicant.full_name
    end
  end

  describe 'interview_confirmation' do
    before :each do
      position = create :position
      @template = create :application_template,
                         position: position, email: 'steve@sharklazers.com'
      application_record = create :application_record, staff_note: 'note',
                                                       position: position
      @interview = create :interview, application_record: application_record
      @user = @interview.user
    end
    let :output do
      JobappsMailer.interview_confirmation @interview
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
    it 'has the correct reply-to address' do
      expect(output.reply_to).to eql Array(@template.email)
    end
  end

  describe 'interview reschedule' do
    before :each do
      position = create :position
      @template = create :application_template,
                         position: position, email: 'steve@sharklazers.com'
      application_record = create :application_record, staff_note: 'note',
                                                       position: position
      @interview = create :interview, application_record: application_record
      @user = @interview.user
    end
    let :output do
      JobappsMailer.interview_reschedule @interview
    end
    it 'emails from the configured value' do
      expect(output.from).to eql Array(@from)
    end
    it 'emails to the interviewee' do
      expect(output.to).to eql Array(@user.email)
    end
    it 'has a subject of interview rescheduled' do
      expect(output.subject).to eql 'Interview Rescheduled'
    end
    it 'includes the date and time of the interview' do
      expect(output.body.encoded).to include @interview.scheduled.to_s
    end
    it 'has the correct reply-to address' do
      expect(output.reply_to).to eql Array(@template.email)
    end
  end

  describe 'send_note_for_later' do
    let(:record) do
      create :application_record,
             saved_for_later: true,
             note_for_later: 'We need you to grow up a little'
    end
    let!(:template) do
      create :application_template,
             position: record.position,
             email: 'steve@sharklazers.com'
    end
    let :output do
      JobappsMailer.send_note_for_later record
    end
    it 'emails from the configured value' do
      expect(output.from).to eql Array(@from)
    end
    it 'emails to the applicant' do
      expect(output.to).to eql Array(record.user.email)
    end
    it 'has the correct reply-to address' do
      expect(output.reply_to)
        .to eql Array(record.position.application_template.email)
    end
    it 'has the correct subject' do
      expect(output.subject)
        .to eql 'Your application has been saved for later review'
    end
    it 'includes the note for later in the body' do
      expect(output.body.encoded).to include record.note_for_later
    end
  end

  describe 'site_text_request' do
    before :each do
      @user = create :user
      @location = 'the desired location'
      @description = 'the description of the text'
    end
    let :output do
      JobappsMailer.site_text_request @user, @location, @description
    end
    it 'emails from the default configured value' do
      expect(output.from).to eql Array(@from)
    end
    it 'emails to the site_text_request_email configured value' do
      expect(output.to)
        .to eql Array(configured_value [:email, :site_contact_email])
    end
    it 'has a subject that includes the words Site text request' do
      expect(output.subject).to include 'Site text request'
    end
    it 'includes the full name of the requesting user' do
      expect(output.body.encoded).to include @user.full_name
    end
    it 'includes the desired location of the site text' do
      expect(output.body.encoded).to include @location
    end
    it 'includes the description of the site text' do
      expect(output.body.encoded).to include @description
    end
    it 'includes the email of the requesting user' do
      expect(output.body.encoded).to include @user.email
    end
  end
end
