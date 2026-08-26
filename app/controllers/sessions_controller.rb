# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authorize_user, :authorize_staff
  skip_forgery_protection

  def create
    set_session
    redirect_to auth_referer || root_path
  end

  def destroy
    session.clear
    if Rails.env.development?
      # simplecov:disable
      redirect_to root_path
      # simplecov:enable
    else
      redirect_to azure_logout_url, allow_other_host: true
    end
  end

  private

  def set_session
    session[:entra_uid] = auth_hash.uid
    session[:email] = auth_hash.info.email
    session[:first_name] = auth_hash.info.first_name
    session[:last_name] = auth_hash.info.last_name
  end

  def auth_hash = request.env['omniauth.auth']

  def auth_referer = request.env['omniauth.origin'].presence
end
