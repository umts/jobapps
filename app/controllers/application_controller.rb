class ApplicationController < ActionController::Base
  include DateAndTimeMethods
  helper_method DateAndTimeMethods.instance_methods

  attr_accessor :current_user
  protect_from_forgery with: :exception
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
end
