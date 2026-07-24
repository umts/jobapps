# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: -> { Rails.configuration.x.app.email[:default_from] }
end
