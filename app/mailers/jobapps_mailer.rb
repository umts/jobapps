class JobappsMailer < ActionMailer::Base
  include ApplicationConfiguration

  def interview_confirmation(interview)
    @interview = interview
    @user = interview.user
    mail from: configured_value([:email, :default_from], default: false),
         to: @user.email,
         subject: 'Interview Confirmation'
  end

  # def application_denial application
  # @application = application
  # @user = application.user
  # mail to: @user.email, subject: 'Application Denial'
  # end
end
