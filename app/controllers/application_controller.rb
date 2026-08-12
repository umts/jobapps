# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_current_user
  before_action :redirect_unauthenticated
  before_action :access_control
  layout 'application'

  private

  # Appended as a before_action in controllers by default
  def access_control
    deny_access unless Current.user.presence&.staff?
  end

  def deny_access
    if request.xhr?
      head :unauthorized
    else
      render file: Rails.public_path.join('401.html'), status: :unauthorized, layout: false
    end
  end

  def redirect_unauthenticated
    return if Current.user.present? || session.key?(:entra_uid)

    redirect_to unauthenticated_session_path
  end

  def set_current_user
    Current.user = User.find_by(entra_uid: session[:entra_uid]) if session.key?(:entra_uid)
  end

  def show_errors(object)
    flash[:errors] = object.errors.full_messages
    redirect_back_or_to root_path
  end
end
