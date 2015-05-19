class SessionsController < ActionController::Base
  def new
    if Rails.env.development?
      redirect_to action: 'dev_login'
    else #production
      #create a session/user
      #redirect to that user's page
    end
  end

  def dev_login
    @staff    = User.staff.limit    5
    @students = User.students.limit 5
  end
end
