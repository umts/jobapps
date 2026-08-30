# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authorize_user, :authorize_staff
  skip_forgery_protection

  def create
    create_or_update_user
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

  # Create the user on first login and keep their name and email in sync with
  # Active Directory on every login (AD is the source of truth). staff and admin
  # default to false for new users.
  def create_or_update_user
    user = User.find_or_initialize_by(entra_uid: auth_hash.uid)
    user.update! email: auth_hash.info.email,
                 first_name: auth_hash.info.first_name,
                 last_name: auth_hash.info.last_name
    session[:entra_uid] = user.entra_uid
  end

  def auth_hash = request.env['omniauth.auth']

  def auth_referer = request.env['omniauth.origin'].presence
end
