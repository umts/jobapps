class JobappsMailer < ActionMailer::Base
  default from: 'transit-it@admin.umass.edu'

  def interview_confirmation(interview)
    @interview = interview
    @user = interview.user
    mail to: @user.email,
         subject: 'Interview Confirmation'
  end

  # TO DO: def instructions. Make configurable in yml file.
  # Not everyone will have a website.
  # def instruction (take what?)
end
