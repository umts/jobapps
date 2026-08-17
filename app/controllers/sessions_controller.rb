# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :access_control, :require_login
  skip_forgery_protection only: :create

  def create
    set_session
    redirect_to auth_referer || main_dashboard_path
  end

  def destroy
    session.clear
    if Rails.env.production?
      redirect_to entra_logout_url, allow_other_host: true
    else
      redirect_to root_path
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

  def entra_logout_url
    tenant_id = Rails.application.credentials.dig(:entra_id, :tenant_id)
    redirect_uri = CGI.escape(root_url)
    "https://login.microsoftonline.com/#{tenant_id}/oauth2/v2.0/logout?post_logout_redirect_uri=#{redirect_uri}"
  end
end
