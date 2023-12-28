# frozen_string_literal: true

class SessionsController < ApplicationController
  # layout without_logout
  layout false
  skip_before_action :access_control, :redirect_unauthenticated,
                     :check_primary_account

  def destroy
    session.clear
    if Rails.env.production?
      redirect_to '/Shibboleth.sso/Logout?return=https://webauth.umass.edu/Logout'
    else
      redirect_to dev_login_path
    end
  end

  # route not defined in production
  def dev_login
    if request.get?
      @staff     = User.staff
      @students  = User.students
      @new_spire = new_spire
    elsif request.post?
      find_user
      redirect_to main_dashboard_path
    end
  end

  # Only shows if no user in database AND no SPIRE provided from Shibboleth
  def unauthenticated; end

  private

  def find_user
    if params.permit(:user_id).present?
      @user = User.find_by(id: params[:user_id])
      session[:user_id] = @user.id
    elsif params.permit(:spire).present?
      session[:spire] = params[:spire]
    end
  end

  def new_spire
    format('%08d@umass.edu', User.maximum(:spire).to_i + 1)
  end
end
