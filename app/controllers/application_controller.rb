# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ApplicationConfiguration

  before_action :set_spire
  before_action :set_current_user
  before_action :redirect_unauthenticated
  before_action :access_control
  before_action :check_primary_account
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
    return if Current.user.present? || session.key?(:spire)

    logger.info 'Request:'
    logger.info request.inspect
    logger.info 'Session:'
    logger.info session.inspect
    redirect_to unauthenticated_session_path
  end

  def set_current_user
    Current.user =
      if session.key? :user_id
        User.find_by id: session[:user_id]
      elsif session.key? :spire
        User.find_by(spire: session[:spire]).tap do |user|
          session[:user_id] = user&.id
        end
      end
  end

  def set_spire
    session[:spire] = request.env['fcIdNumber'] if request.env.key? 'fcIdNumber'
  end

  def show_errors(object)
    flash[:errors] = object.errors.full_messages
    redirect_back_or_to('/404.html')
  end

  def check_primary_account
    return if request.env['UMAPrimaryAccount'] == request.env['uid']

    @primary_account = request.env['UMAPrimaryAccount']
    @uid = request.env['uid']
    render 'sessions/unauthenticated_subsidiary',
           status: :unauthorized,
           layout: false
  end
end
