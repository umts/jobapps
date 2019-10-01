require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'

Bundler.require(*Rails.groups)

module Jobapps
  class Application < Rails::Application
    config.encoding = 'utf-8'
    config.time_zone = 'Eastern Time (US & Canada)'
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('vendor/lib')
    config.filter_parameters += [:password, :secret, :spire, :github]
    config.assets.paths << Rails.root.join('node_modules')
  end
end
