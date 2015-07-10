class SessionsController < ApplicationController
  # layout without_logout
  layout false
  skip_before_action :access_control, :set_current_user, :set_spire

  def destroy
    if Rails.env.production?
      redirect_to '/Shibboleth.sso/Logout?return=https://webauth.oit.umass.edu/Logout'
    else redirect_to dev_login_sessions_path
    end
    session.clear
  end

  # '... and return' is correct behavior here, disable rubocop warning
  # rubocop:disable Style/AndOr
  def dev_login
    if request.get?
      @staff     = User.staff
      @students  = User.students
      @new_spire = (User.pluck(:spire).map(&:to_i).last + 1).to_s.rjust 8, '0'
    elsif request.post?
      find_user
      redirect_to main_dashboard_path
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
    if params.permit(:user_id).present?
      @user = User.find_by(id: params[:user_id])
      session[:user_id] = @user.id
    elsif params.permit(:spire).present?
      session[:spire] = params[:spire]
    end
  end
end
