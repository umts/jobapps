# frozen_string_literal: true

module Routable
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
  end

  delegate :default_url_options, to: :'ActionMailer::Base'

  def url
    url_for self
  end
end
