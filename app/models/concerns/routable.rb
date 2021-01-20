# frozen_string_literal: true

module Routable
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
  end

  def default_url_options
    ActionMailer::Base.default_url_options
  end

  def url
    url_for self
  end
end
