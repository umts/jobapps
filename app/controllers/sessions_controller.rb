class SessionsController < ApplicationController
  #layout without_logout
  layout false

  def destroy
    if Rails.env.development?
      redirect_to dev_login_sessions_path
    else #production
      #redirect_to '/Shibboleth.sso/Logout?return=https://webauth.oit.umass.edu/Logout'
    end
    session.clear
  end

  def dev_login
    if Rails.env.production?
      redirect_to new_session_path and return
    else
      if request.get?
        @staff    = User.staff.limit    5
        @students = User.students.limit 5
      elsif request.post?
        params.require :user_id
        user = User.where(id: params[:user_id]).first
        session[:user_id] = user.id
        redirect_to main_dashboard_path
      end
    end
  end
 
  def new
    if Rails.env.development?
      redirect_to action: 'dev_login'
    else #production
    end
  end

end
