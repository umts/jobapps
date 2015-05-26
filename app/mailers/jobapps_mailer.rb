class JobappsMailer < ActionMailer::Base
default from: 'transit-it@admin.umass.edu'

  def interview_confirmation interview
    @interview = interview
    @user = interview.user
    mail to: @user.email
         subject: 'Interview Confirmation'
  end

end
