class SessionsController < ApplicationController
  layout false

  def destroy
    if Rails.env.development?
      redirect_to root_path
    else #production
      #redirect_to '/Shibboleth.sso/Logout?return=https://webauth.oit.umass.edu/Logout'
    end
    session.clear
  end

  def dev_login
    if request.get?
      @staff    = User.staff.limit    5
      @students = User.students.limit 5
    elsif request.post?
      user = User.where(id: params.fetch(:user_id)).first
      session[:user_id] = user.id
      redirect_to user
    end
  end

  def new
    if Rails.env.development?
      redirect_to action: 'dev_login'
    else #production
    end
  end
end
