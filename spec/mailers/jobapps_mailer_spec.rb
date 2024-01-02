# frozen_string_literal: true

require 'rails_helper'
require 'application_configuration'

describe JobappsMailer do
  let(:config) { ApplicationConfiguration }
  let(:from) { config.configured_value %i[email default_from] }

  describe '.application_denial' do
    subject(:output) { described_class.application_denial application_submission }

    let(:position) { create(:position) }

    let! :template do
      create(:application_template, position:, email: 'steve@sharklazers.com')
    end

    let :application_submission do
      create(:application_submission, staff_note: 'note', position:)
    end

    it 'emails from the configured value' do
      expect(output.from).to eq(Array(from))
    end

    it 'emails to the applicant' do
      expect(output.to).to eq([application_submission.user.email])
    end

    it 'has a subject of application denial' do
      expect(output.subject).to eq('Application Denial')
    end

    it 'has the correct reply-to' do
      expect(output.reply_to).to eq([template.email])
    end

    context 'when a rejection message exists' do
      before do
        application_submission.update rejection_message: 'You like dags?'
      end

      it 'includes a reason for application denial' do
        expect(output.body.encoded).to include(application_submission.rejection_message)
      end
    end

    context 'when a rejection message does not exist' do
      it 'does not include a reason for application denial' do
        message = 'Your application to the ' \
                  "#{application_submission.position.name} position has been denied."
        expect(output.body.encoded).to include(message)
      end
    end
  end

  describe '.application_notification' do
    subject :output do
      described_class.application_notification subscription, position, applicant
    end

    let(:position) { create(:position) }
    let(:subscription) { create(:subscription, position:) }
    let(:applicant) { create(:user, :student) }

    it 'emails from the configured value' do
      expect(output.from).to eq(Array(from))
    end

    it 'emails to the subscriber email' do
      expect(output.to).to eq([subscription.email])
    end

    it 'has a subject notifying the subscriber of the message purpose' do
      expect(output.subject).to eq("New application for #{position.name}")
    end

    it 'includes the position name and the name of the applicant' do
      expect(output.body).to include(position.name, applicant.full_name)
    end
  end

  describe '.interview_confirmation' do
    subject(:output) { described_class.interview_confirmation interview }

    let(:position) { create(:position) }

    let! :template do
      create(:application_template, position:, email: 'steve@sharklazers.com')
    end

    let :interview do
      application_submission = create(:application_submission, staff_note: 'note', position:)
      create(:interview, application_submission:)
    end

    it 'emails from the configured value' do
      expect(output.from).to eq(Array(from))
    end

    it 'emails to the interviewee' do
      expect(output.to).to eq([interview.user.email])
    end

    it 'has a subject of interview confirmation' do
      expect(output.subject).to eq('Interview Confirmation')
    end

    it 'includes the date and time of the interview' do
      expect(output.body.encoded).to include(interview.scheduled.to_s)
    end

    it 'has the correct reply-to address' do
      expect(output.reply_to).to eq([template.email])
    end
  end

  describe '.interview_reschedule' do
    subject(:output) { described_class.interview_reschedule interview }

    let(:position) { create(:position) }

    let! :template do
      create(:application_template, position:, email: 'steve@sharklazers.com')
    end

    let :interview do
      application_submission = create(:application_submission, staff_note: 'note', position:)
      create(:interview, application_submission:)
    end

    it 'emails from the configured value' do
      expect(output.from).to eq(Array(from))
    end

    it 'emails to the interviewee' do
      expect(output.to).to eq([interview.user.email])
    end

    it 'has a subject of interview rescheduled' do
      expect(output.subject).to eq('Interview Rescheduled')
    end

    it 'includes the date and time of the interview' do
      expect(output.body.encoded).to include(interview.scheduled.to_s)
    end

    it 'has the correct reply-to address' do
      expect(output.reply_to).to eq([template.email])
    end
  end

  describe '.send_note_for_later' do
    subject(:output) { described_class.send_note_for_later record }

    let :record do
      create(:application_submission, saved_for_later: true,
                                      note_for_later: 'We need you to grow up a little')
    end

    let! :template do
      create(:application_template, position: record.position, email: 'steve@sharklazers.com')
    end

    it 'emails from the configured value' do
      expect(output.from).to eq(Array(from))
    end

    it 'emails to the applicant' do
      expect(output.to).to eq([record.user.email])
    end

    it 'has the correct reply-to address' do
      expect(output.reply_to).to eq([template.email])
    end

    it 'has the correct subject' do
      expect(output.subject).to eq('Your application has been saved for later review')
    end

    it 'includes the note for later in the body' do
      expect(output.body.encoded).to include(record.note_for_later)
    end
  end

  describe '.saved_application_notification' do
    subject(:output) { described_class.saved_application_notification record }

    let(:record) { create(:application_submission, email_to_notify: 'foo@example.com') }

    it 'emails to the email_to_notify value' do
      expect(output.to).to eq(['foo@example.com'])
    end

    it 'has a subject that includes the words Saved application' do
      expect(output.subject).to include('Saved application')
    end

    it 'includes the position name' do
      expect(output.body.encoded).to include(record.position.name)
    end

    it "includes the applicant's full name" do
      expect(output.body.encoded).to include(record.user.full_name)
    end

    it 'includes the date applied' do
      expect(output.body.encoded).to include(record.created_at.to_formatted_s(:long_with_time))
    end

    it 'includes the note for later if it exists' do
      record.update note_for_later: 'This note is for later.'
      expect(output.body.encoded).to include(record.note_for_later)
    end
  end

  describe '.saved_applications_notification' do
    subject :output do
      described_class.saved_applications_notification({ position => records }, email)
    end

    let(:position) { create(:position) }
    let :records do
      [
        create(:application_submission, position:, note_for_later: 'This note is for later.'),
        create(:application_submission, position:)
      ]
    end

    let(:email) { 'foo@example.com' }

    it 'emails from default configured value' do
      expect(output.to).to contain_exactly(email)
    end

    it 'has a subject that includes the words Saved applications' do
      expect(output.subject).to include('Saved applications')
    end

    it 'includes the position names' do
      expect(output.body.encoded).to include(position.name)
    end

    it "includes the applicants' full name" do
      expect(output.body.encoded).to include(*records.map { |r| r.user.full_name })
    end

    it 'includes the dates applied' do
      dates = records.map { |r| r.created_at.to_formatted_s(:long_with_time) }
      expect(output.body.encoded).to include(*dates)
    end

    it 'includes any notes for later' do
      expect(output.body.encoded).to include(records[0].note_for_later)
    end
  end
end
