# frozen_string_literal: true

module Authorizable
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user
    before_action :authorize_user
    before_action :authorize_staff
    rescue_from Unauthorized do |exception|
      if session[:entra_uid].present?
        raise exception
        # simplecov:disable
      elsif request.format.html? && Rails.env.production?
        render 'application/production_login', layout: false, status: :unauthorized
      elsif request.format.html? && Rails.env.development?
        render 'application/development_login', layout: 'layouts/application', status: :unauthorized
        # simplecov:enable
      else
        head :unauthorized
      end
    end
  end

  private

  def authorize_user
    raise Unauthorized if session[:entra_uid].blank?
  end

  def authorize_staff
    raise Unauthorized unless Current.user&.staff?
  end

  def set_current_user
    Current.user = User.find_by(entra_uid: session[:entra_uid])
  end
end
