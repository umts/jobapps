# frozen_string_literal: true

require 'rails_helper'
require 'application_configuration'

describe JobappsMailer do
  let(:config) { ApplicationConfiguration }

  before do
    @from = config.configured_value %i[email default_from]
  end

  describe 'application denial' do
    before do
      position = create(:position)
      @template = create(:application_template, position:, email: 'steve@sharklazers.com')
      @application_submission = create(:application_submission, staff_note: 'note', position:)
      @user = @application_submission.user
    end

    let :output do
      JobappsMailer.application_denial @application_submission
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

    context 'rejection_message exists' do
      before do
        @application_submission.update(
          rejection_message: 'You like dags?'
        )
      end

      it 'includes a reason for application denial' do
        expect(output.body.encoded)
          .to include @application_submission.rejection_message
      end
    end

    context 'rejection_message does not exist' do
      it 'does not include a reason for application denial' do
        message = 'Your application to the ' \
                  "#{@application_submission.position.name} position has been denied."
        expect(output.body.encoded).to include message
      end
    end
  end

  describe 'application_notification' do
    let(:position) { create(:position) }
    let(:subscription) { create(:subscription, position:) }
    let(:applicant) { create(:user, :student) }
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
    before do
      position = create(:position)
      @template = create(:application_template, position:, email: 'steve@sharklazers.com')
      application_submission = create(:application_submission, staff_note: 'note', position:)
      @interview = create(:interview, application_submission:)
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
    before do
      position = create(:position)
      @template = create(:application_template, position:, email: 'steve@sharklazers.com')
      application_submission = create(:application_submission, staff_note: 'note', position:)
      @interview = create(:interview, application_submission:)
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
    let :record do
      create(:application_submission, saved_for_later: true,
                                      note_for_later: 'We need you to grow up a little')
    end
    let! :template do
      create(:application_template, position: record.position, email: 'steve@sharklazers.com')
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
        .to eql Array(template.email)
    end

    it 'has the correct subject' do
      expect(output.subject)
        .to eql 'Your application has been saved for later review'
    end

    it 'includes the note for later in the body' do
      expect(output.body.encoded).to include record.note_for_later
    end
  end

  describe 'saved_application_notification' do
    before do
      @record = create(:application_submission, email_to_notify: 'foo@example.com')
    end

    let :output do
      JobappsMailer.saved_application_notification @record
    end

    it 'emails to the email_to_notify value' do
      expect(output.to).to eql Array('foo@example.com')
    end

    it 'has a subject that includes the words Saved application' do
      expect(output.subject).to include 'Saved application'
    end

    it 'includes the position name' do
      expect(output.body.encoded).to include @record.position.name
    end

    it "includes the applicant's full name" do
      expect(output.body.encoded).to include @record.user.full_name
    end

    it 'includes the date applied' do
      expect(output.body.encoded).to include
      @record.created_at.to_formatted_s(:long_with_time)
    end

    it 'includes the note for later if it exists' do
      @record.update note_for_later: 'This note is for later.'
      expect(output.body.encoded).to include @record.note_for_later
    end
  end

  describe 'saved_applications_notification' do
    before do
      @position = create(:position)
      @record1 = create(:application_submission, position: @position,
                                                 note_for_later: 'This note is for later.')
      @record2 = create(:application_submission, position: @position)
      @email = 'foo@example.com'
    end

    let :output do
      info = { @position => [@record1, @record2] }
      JobappsMailer.saved_applications_notification info, @email
    end

    it 'emails from default configured value' do
      expect(output.to).to contain_exactly @email
    end

    it 'has a subject that includes the words Saved applications' do
      expect(output.subject).to include 'Saved applications'
    end

    it 'includes the position names' do
      expect(output.body.encoded).to include @position.name
    end

    it "includes the applicants' full name" do
      expect(output.body.encoded).to include @record1.user.full_name
      expect(output.body.encoded).to include @record2.user.full_name
    end

    it 'includes the dates applied' do
      expect(output.body.encoded)
        .to include @record1.created_at.to_formatted_s(:long_with_time)
      expect(output.body.encoded)
        .to include @record2.created_at.to_formatted_s(:long_with_time)
    end

    it 'includes any notes for later' do
      expect(output.body.encoded).to include @record1.note_for_later
    end
  end
end
