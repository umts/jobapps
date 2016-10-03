class JobappsMailer < ActionMailer::Base
  include ApplicationConfiguration
  helper_method :configured_value

  # for some reason the configured_value method doesn't work here
  default from: CONFIG[:email][:default_from]

  def application_denial(application_record)
    @application_record = application_record
    @user = application_record.user
    template = application_record.position.application_template
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
    template = interview.application_record.position.application_template
    reply_to = template.try :email
    mail to: @user.email,
         subject: 'Interview Confirmation',
         reply_to: reply_to
  end

  def interview_reschedule(interview)
    @interview = interview
    @user = interview.user
    template = interview.application_record.position.application_template
    reply_to = template.try :email
    mail to: @user.email,
         subject: 'Interview Rescheduled',
         reply_to: reply_to
  end

  def send_note_for_later(application_record)
    template = application_record.position.application_template
    @user = application_record.user
    @record = application_record
    reply_to = template.try :email
    mail to: @user.email
         subject: 'Your application has been saved for later review',
         reply_to: reply_to
  end

  def site_text_request(user, location, description)
    @user = user
    @location = location
    @description = description
    mail to: configured_value([:email, :site_contact_email]),
         subject: "Site text request from #{user.full_name}"
  end
end
