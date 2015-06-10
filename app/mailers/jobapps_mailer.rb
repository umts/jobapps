class JobappsMailer < ActionMailer::Base
  include ApplicationConfiguration
  helper_method :configured_value

  def interview_confirmation(interview)
    @interview = interview
    @user = interview.user
    mail from: configured_value([:email, :default_from], default: false),
         to: @user.email,
         subject: 'Interview Confirmation'
  end

  def interview_reschedule(interview)
    @interview = interview
    @user = interview.user
    mail from: configured_value([:email, :default_from], default: false),
         to: @user.email,
         subject: 'Interview Rescheduled'
  end

  def application_denial(application_record)
    @application_record = application_record
    @user = application_record.user
    mail from: configured_value([:email, :default_from], default: false),
         to: @user.email,
         subject: 'Application Denial'
  end
end
