# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ApplicationConfiguration
  include ConfigurableMessages
  include DateAndTimeMethods

  attr_accessor :current_user
  before_action :set_spire
  before_action :set_current_user
  before_action :redirect_unauthenticated
  before_action :access_control
  before_action :check_primary_account
  layout 'application'

  private

  # Appended as a before_action in controllers by default
  # '... and return' is the correct behavior here, disable rubocop warning
  # rubocop:disable Style/AndOr
  def access_control
    deny_access and return unless @current_user.present? && @current_user.staff?
  end
  # rubocop:enable Style/AndOr

  def deny_access
    if request.xhr?
      head :unauthorized
    else
      render file: 'public/401.html',
             status: :unauthorized,
             layout: false
    end
  end

  # '... and return' is the correct behavior here, disable rubocop warning
  # rubocop:disable Style/AndOr
  def redirect_unauthenticated
    return if @current_user.present? || session.key?(:spire)

    logger.info 'Request:'
    logger.info request.inspect
    logger.info 'Session:'
    logger.info session.inspect
    redirect_to unauthenticated_session_path and return
  end
  # rubocop:enable Style/AndOr

  def set_current_user
    @current_user =
      if session.key? :user_id
        User.find_by id: session[:user_id]
      elsif session.key? :spire
        User.find_by spire: session[:spire]
      end
  end

  def set_spire
    session[:spire] = request.env['fcIdNumber'] if request.env.key? 'fcIdNumber'
  end

  # '... and return' is the correct behavior here, disable rubocop warning
  # rubocop:disable Style/AndOr
  def show_errors(object)
    flash[:errors] = object.errors.full_messages
    redirect_back(fallback_location: 'public/404.html') and return
  end
  # rubocop:enable Style/AndOr

  def check_primary_account
    return if request.env['UMAPrimaryAccount'] == request.env['uid']

    @primary_account = request.env['UMAPrimaryAccount']
    @uid = request.env['uid']
    render 'sessions/unauthenticated_subsidiary',
           status: :unauthorized,
           layout: false
  end
end
