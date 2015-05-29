class ApplicationController < ActionController::Base
  include BeforeRender
  include DateAndTimeMethods
  helper_method DateAndTimeMethods.instance_methods

  attr_accessor :current_user
  protect_from_forgery with: :exception
  before_action :set_current_user, unless: -> { params[:skip_current_user]}
  attr_accessor :permit_student_access
  before_render :access_control
  layout 'application'

  rescue_from AccessDeniedException do
    if request.xhr?
      render nothing: true, status: :unauthorized
    else render file: 'public/401.html', status: :unauthorized, layout: false
    end
  end

  private

  def access_control
    if @current_user.present? && @current_user.student? && !@permit_student_access
      raise AccessDeniedException
    end
  end

  def permit_student_access
    @permit_student_access = true
  end

  def set_current_user
    if session[:user_id].present?
      @current_user = User.find session[:user_id]
    else
      redirect_to new_session_path
    end
  end
end
