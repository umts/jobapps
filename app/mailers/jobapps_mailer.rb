class JobappsMailer < ActionMailer::Base
  include ApplicationConfiguration
  helper_method :configured_value

  # for some reason the configured_value method doesn't work here
  default from: CONFIG[:email][:default_from]

  def application_denial(application_submission)
    @application_submission = application_submission
    @user = @application_submission.user
    template = @application_submission.position.application_template
    reply_to = template.try :email
    mail to: @user.email,
         subject: 'Application Denial',
         reply_to: reply_to
  end

  def application_notification(subscription, position, applicant)
    @position = position
    @applicant = applicant
    mail to: subscription.email,
         subject: "New application for #{position.name}"
  end

  def interview_confirmation(interview)
    @interview = interview
    @user = interview.user
    template = interview.application_submission.position.application_template
    reply_to = template.try :email
    mail to: @user.email,
         subject: 'Interview Confirmation',
         reply_to: reply_to
  end

  def interview_reschedule(interview)
    @interview = interview
    @user = interview.user
    template = interview.application_submission.position.application_template
    reply_to = template.try :email
    mail to: @user.email,
         subject: 'Interview Rescheduled',
         reply_to: reply_to
  end

  def send_note_for_later(application_submission)
    template = application_submission.position.application_template
    @user = application_submission.user
    @record = application_submission
    reply_to = template.try :email
    mail to: @user.email,
         subject: 'Your application has been saved for later review',
         reply_to: reply_to
  end

  def site_text_request(user, location, description)
    @user = user
    @location = location
    @description = description
    mail to: configured_value(%i[email site_contact_email]),
         subject: "Site text request from #{user.full_name}"
  end

  def saved_application_notification(record)
    @record = record
    mail to: record.email_to_notify,
         subject: 'Saved application moved back to dashboard'
  end

  def saved_applications_notification(records, email)
    @records = records
    mail to: email,
         subject: 'Saved applications moved back to dashboard'
  end
end
