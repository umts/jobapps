class SessionsController < ApplicationController
  # layout without_logout
  layout false
  skip_before_action :require_current_user, :access_control

  def destroy
    if Rails.env.production?
      # redirect_to '/Shibboleth.sso/Logout?return=https://webauth.oit.umass.edu/Logout'
    else redirect_to dev_login_sessions_path
    end
    session.clear
  end

  # '... and return' is correct behavior here, disable rubocop warning
  # rubocop:disable Style/AndOr
  def dev_login
    if Rails.env.production?
      redirect_to new_session_path and return
    else
      if request.get?
        @staff    = User.staff.limit 5
        @students = User.students.limit 5
      elsif request.post?
        find_user
        redirect_to main_dashboard_path
      end
    end
  end
  # '... and return' is correct behavior here, disable rubocop warning
  # rubocop:enable Style/AndOr

  def new
    if Rails.env.production?
      # TODO: decide on this behavior
    else
      redirect_to dev_login_sessions_path
    end
  end

  private

  def find_user
    params.require :user_id
    @user = User.find_by(id: params[:user_id])
    session[:user_id] = @user.id
  end
end
