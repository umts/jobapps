# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_current_user
  before_action :require_login
  before_action :access_control
  layout 'application'

  # Access-control callbacks raise Unauthorized rather than rendering directly,
  # so the response is decided in one place as a reply to the original request:
  # an unauthenticated visitor gets the login page (401) rendered where they
  # stood (so omniauth.origin can send them back), while an authenticated but
  # unpermitted user gets a forbidden page (403).
  rescue_from Unauthorized do
    if session.key?(:entra_uid)
      render_forbidden
    else
      render_login
    end
  end

  private

  # Appended as a before_action in controllers by default
  def access_control
    raise Unauthorized unless Current.user.presence&.staff?
  end

  def require_login
    raise Unauthorized unless session.key?(:entra_uid)
  end

  def render_forbidden
    if request.xhr?
      head :forbidden
    else
      render file: Rails.public_path.join('403.html'), status: :forbidden, layout: false
    end
  end

  def render_login
    if Rails.env.production? || Rails.env.development?
      respond_to do |format|
        # Force the application layout so the login page renders consistently
        # even when the rescue fires from a controller with its own layout
        # (e.g. the maintenance_tasks engine).
        format.html { render "application/#{Rails.env}_login", layout: 'application', status: :unauthorized }
        format.all { head :unauthorized }
      end
    else
      head :unauthorized
    end
  end

  def set_current_user
    Current.user = User.find_by(entra_uid: session[:entra_uid]) if session.key?(:entra_uid)
  end

  def show_errors(object)
    flash[:errors] = object.errors.full_messages
    redirect_back_or_to root_path
  end
end
