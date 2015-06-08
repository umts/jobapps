class JobappsMailer < ActionMailer::Base
  default from: 'transit-it@admin.umass.edu'

  def interview_confirmation(interview)
    @interview = interview
    @user = interview.user
    mail to: @user.email,
         subject: 'Interview Confirmation'
  end
  
  #def application_denial application
  #@application = application
  #@user = application.user
  #mail to: @user.email, subject: 'Application Denial'
  #end
end
