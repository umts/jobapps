class ApplicationController < ActionController::Base
  include ApplicationConfiguration
  include ConfigurableMessages
  include DateAndTimeMethods

  attr_accessor :current_user
  protect_from_forgery with: :exception
  before_action :set_current_user
  before_action :set_spire, if: -> { @current_user.blank? }
  # To allow student users or even non-users to access pages,
  # skip this before_action in the individual controller.
  before_action :access_control
  layout 'application'

  private

  # Appended as a before_action in controllers by default
  # '... and return' is the correct behavior here, disable rubocop warning
  # rubocop:disable Style/AndOr
  def access_control
    deny_access and return unless @current_user.present? && @current_user.staff?
  end
  # rubocop:enable Style/AndOr

  def current_user_exists?
    session.key?(:user_id) && User.find_by(id: session[:user_id]).present?
  end

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
    @current_user = User.find session[:user_id] if current_user_exists?
  end

  # '... and return' is the correct behavior here, disable rubocop warning
  # rubocop:disable Style/AndOr
  def set_spire
    if spire_exists?
      session[:spire] ||= request.env['SPIRE_ID']
    else # no spire in session from initial request and none in current request
      redirect_to unauthenticated_session_path and return
    end
  end
  # rubocop:enable Style/AndOr

  def spire_exists?
    session.key?(:spire) || request.env.key?('SPIRE_ID')
  end

  # '... and return' is the correct behavior here, disable rubocop warning
  # rubocop:disable Style/AndOr
  def show_errors(object)
    flash[:errors] = object.errors.full_messages
    redirect_to :back and return
  end
  # rubocop:enable Style/AndOr
end
