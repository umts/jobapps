# frozen_string_literal: true

OmniAuth.config.logger = Rails.logger
OmniAuth.config.request_validation_phase = OmniAuth::AuthenticityTokenProtection.new(key: :_csrf_token)

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :entra_id, Rails.application.credentials[:entra_id] unless Rails.env.test?
  provider :developer, fields: %i[uid email first_name last_name], uid_field: :uid unless Rails.env.production?
end
