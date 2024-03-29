# frozen_string_literal: true

class JobappsMailer < ApplicationMailer
  def application_denial(application_submission)
    @application_submission = application_submission
    @user = @application_submission.user
    template = @application_submission.position.application_template
    reply_to = template.try :email
    mail to: @user.email, subject: 'Application Denial', reply_to:
  end

  def application_notification(subscription, position, applicant)
    @position = position
    @applicant = applicant
    mail to: subscription.email, subject: "New application for #{position.name}"
  end

  def interview_confirmation(interview)
    @interview = interview
    @user = interview.user
    template = interview.application_submission.position.application_template
    reply_to = template.try :email
    mail to: @user.email, subject: 'Interview Confirmation', reply_to:
  end

  def interview_reschedule(interview)
    @interview = interview
    @user = interview.user
    template = interview.application_submission.position.application_template
    reply_to = template.try :email
    mail to: @user.email, subject: 'Interview Rescheduled', reply_to:
  end

  def send_note_for_later(application_submission)
    template = application_submission.position.application_template
    @user = application_submission.user
    @record = application_submission
    reply_to = template.try :email
    mail to: @user.email, reply_to:,
         subject: 'Your application has been saved for later review'
  end

  def saved_application_notification(record)
    @record = record
    mail to: record.email_to_notify,
         subject: 'Saved application moved back to dashboard'
  end

  def saved_applications_notification(records, email)
    @records = records
    mail to: email, subject: 'Saved applications moved back to dashboard'
  end
end
