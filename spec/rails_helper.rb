ENV['RAILS_ENV'] ||= 'test'
require 'factory_bot_rails'
require 'rspec-html-matchers'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'rack_session_access/capybara'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
end
