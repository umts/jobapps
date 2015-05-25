class ApplicationController < ActionController::Base
  include DateAndTimeMethods
  helper_method DateAndTimeMethods.instance_methods

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :site_texts
<<<<<<< HEAD
  before_action :current_user, unless: -> { params[:skip_current_user] }
=======
  before_action :set_current_user
>>>>>>> 2c3f840ac3913c9c5ffac8bceb8e1850935086c2
  layout 'application'

  private

<<<<<<< HEAD
  def current_user
    if session[:user_id].present?
      @current_user = User.find session[:user_id]
    else
      redirect_to new_session_path
    end
=======
  def set_current_user
    @current_user = User.find session[:user_id] if session[:user_id].present?
>>>>>>> 2c3f840ac3913c9c5ffac8bceb8e1850935086c2
  end

  def site_texts
    @site_texts = SiteText.order :name
  end
end
