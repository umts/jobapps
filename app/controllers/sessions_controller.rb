# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authorize_user, :authorize_staff
  skip_forgery_protection

  def create
    session[:entra_uid] = auth_hash.uid
    User.create_with(user_create_attrs).find_or_initialize_by(entra_uid: auth_hash.uid).update!(user_update_attrs)
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

  def auth_hash = request.env['omniauth.auth']

  def auth_referer = request.env['omniauth.origin'].presence

  def user_create_attrs = { email: auth_hash.info.email }

  def user_update_attrs
    { first_name: auth_hash.info.first_name,
      last_name: auth_hash.info.last_name,
      entra_upn: auth_hash.extra&.raw_info&.upn }.compact_blank
  end
end
