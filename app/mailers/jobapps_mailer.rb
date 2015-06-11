class JobappsMailer < ActionMailer::Base
  include ApplicationConfiguration
  helper_method :configured_value

  def application_denial(application_record)
    @application_record = application_record
    @user = application_record.user
    mail from: configured_value([:email, :default_from]),
         to: @user.email,
         subject: 'Application Denial'
  end

  def interview_confirmation(interview)
    @interview = interview
    @user = interview.user
    mail from: configured_value([:email, :default_from]),
         to: @user.email,
         subject: 'Interview Confirmation'
  end

  def interview_reschedule(interview)
    @interview = interview
    @user = interview.user
    mail from: configured_value([:email, :default_from]),
         to: @user.email,
         subject: 'Interview Rescheduled'
  end

  def site_text_request(user, location, description)
    @user = user
    @location = location
    @description = description
    mail from: configured_value([:email, :default_from]),
         to:   configured_value([:email, :site_text_request_address]),
         subject: "Site text request from #{user.full_name}"
  end
end
