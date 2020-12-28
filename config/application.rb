require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'

Bundler.require(*Rails.groups)

module Jobapps
  class Application < Rails::Application
    config.load_defaults 5.2
    config.encoding = 'utf-8'
    config.time_zone = 'Eastern Time (US & Canada)'
    config.filter_parameters += [:password, :secret, :spire, :github]
  end
end
