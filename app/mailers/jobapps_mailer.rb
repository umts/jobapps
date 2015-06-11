class JobappsMailer < ActionMailer::Base
  include ApplicationConfiguration
  helper_method :configured_value

  # for some reason the configured_value method doesn't work here
  default from: CONFIG[:email][:default_from]

  def application_denial(application_record)
    @application_record = application_record
    @user = application_record.user
    mail to: @user.email,
         subject: 'Application Denial'
  end

  def interview_confirmation(interview)
    @interview = interview
    @user = interview.user
    mail to: @user.email,
         subject: 'Interview Confirmation'
  end

  def interview_reschedule(interview)
    @interview = interview
    @user = interview.user
    mail to: @user.email,
         subject: 'Interview Rescheduled'
  end

  def site_text_request(user, location, description)
    @user = user
    @location = location
    @description = description
    mail to: configured_value([:email, :site_text_request_address]),
         subject: "Site text request from #{user.full_name}"
  end
end
