class SessionsController < ApplicationController
  #layout without_logout
  layout false

  #root
  def create
    if Rails.env.development?
      redirect_to action: 'dev_login'
    else #production
    end
  end

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
      params.require :user_id
      user = User.where(id: params[:user_id]).first
      session[:user_id] = user.id
      redirect_to controller: 'dashboard',
                  action: user.staff? ? 'staff' : 'student'
    end
  end
end
