class ApplicationController < ActionController::Base
  include DateAndTimeMethods
  helper_method DateAndTimeMethods.instance_methods

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :site_texts
  before_action :set_current_user, unless: -> { params[:skip_current_user] }
  layout 'application'

  private

  def set_current_user
    if session[:user_id].present?
      @current_user = User.find session[:user_id]
    else
      redirect_to new_session_path
    end
  end

  def site_texts
    @site_texts = SiteText.order :name
  end
end
