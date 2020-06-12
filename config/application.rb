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
    config.assets.paths << Rails.root.join('node_modules')
    config.filter_parameters += [:password, :secret, :spire, :github]
    config.assets.paths << Rails.root.join('node_modules')
    config.action_view.form_with_generates_ids = true
  end
end
