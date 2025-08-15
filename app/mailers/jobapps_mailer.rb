# frozen_string_literal: true

class JobappsMailer < ApplicationMailer
  def application_denial(application_submission)
    @application_submission = application_submission
    @user = @application_submission.user
    template = @application_submission.position.application_template
    mail to: @user.email, reply_to: template&.email
  end

  def application_notification(subscription, position, applicant)
    @position = position
    @applicant = applicant
    mail to: subscription.email, subject: default_i18n_subject(position: position.name)
  end

  def interview_confirmation(interview)
    @interview = interview
    @user = interview.user
    template = interview.application_submission.position.application_template
    mail to: @user.email, reply_to: template&.email
  end

  def interview_reschedule(interview)
    @interview = interview
    @user = interview.user
    template = interview.application_submission.position.application_template
    mail to: @user.email, reply_to: template&.email
  end

  def send_note_for_later(application_submission)
    template = application_submission.position.application_template
    @user = application_submission.user
    @record = application_submission
    mail to: @user.email, reply_to: template&.email
  end

  def saved_application_notification(record)
    @record = record
    mail to: record.email_to_notify
  end

  def saved_applications_notification(records, email)
    @records = records
    mail to: email
  end
end
