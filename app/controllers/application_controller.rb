class ApplicationController < ActionController::Base
  include BeforeRender
  include DateAndTimeMethods
  helper_method DateAndTimeMethods.instance_methods

  attr_accessor :current_user
  protect_from_forgery with: :exception
  before_action :set_current_user, unless: -> { params[:skip_current_user]}
  before_action :access_control
  layout 'application'

  private

  def access_control
    deny_access if @current_user.student?
  end

  def deny_access
    if request.xhr?
      render nothing: true, status: :unauthorized and return
    else render file: 'public/401.html', status: :unauthorized, layout: false and return
    end
  end

  def set_current_user
    if session[:user_id].present?
      @current_user = User.find session[:user_id]
    else
      redirect_to new_session_path
    end
  end

  def show_errors object
    flash[:errors] = object.errors.full_messages
    redirect_to :back and return
  end
end
