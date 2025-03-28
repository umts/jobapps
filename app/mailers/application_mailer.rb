# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  include ApplicationConfiguration

  helper_method :configured_value

  default from: ApplicationConfiguration.configured_value(%i[email default_from])
end
