class ApplicationController < ActionController::Base
  include ApplicationConfiguration
  include ConfigurableMessages
  include DateAndTimeMethods

  attr_accessor :current_user
  protect_from_forgery with: :exception
  before_action :set_current_user
  # To allow student users or even non-users to access pages,
  # skip this before_action in the individual controller.
  before_action :access_control
  layout 'application'

  private

  # Appended as a before_action in controllers by default
  # '... and return' is the correct behavior here, disable rubocop warning
  # rubocop:disable Style/AndOr
  def access_control
    redirect_to new_session_path and return if @current_user.blank?
    deny_access and return if @current_user.student?
  end
  # rubocop:enable Style/AndOr

  def deny_access
    if request.xhr?
      render nothing: true, status: :unauthorized
    else
      render file: 'public/401.html',
             status: :unauthorized,
             layout: false
    end
  end
  
  def set_current_user
    if session.key?(:user_id) && User.find_by(id: session[:user_id]).present?
      @current_user = User.find session[:user_id]
    elsif request.env.key? 'SPIRE_ID'
      session['spire'] = request.env['SPIRE_ID']
    end
  end

  # '... and return' is the correct behavior here, disable rubocop warning
  # rubocop:disable Style/AndOr
  def show_errors(object)
    flash[:errors] = object.errors.full_messages
    redirect_to :back and return
  end
  # rubocop:enable Style/AndOr
end
