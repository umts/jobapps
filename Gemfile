# frozen_string_literal: true

source 'https://rubygems.org'
ruby IO.read(File.expand_path('.ruby-version', __dir__)).strip

gem 'bootstrap', '~> 4.0'
gem 'coffee-rails'
gem 'friendly_id', '~> 5.1.0'
gem 'haml'
gem 'haml-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'mysql2'
gem 'prawn'
gem 'prawn-table'
gem 'rails', '~> 5.2.0'
gem 'redcarpet'
gem 'sass-rails'
gem 'snappconfig'
gem 'strscan'
gem 'uglifier'
gem 'whenever', require: false

group :production do
  gem 'exception_notification'
end

group :development do
  gem 'capistrano', '~> 3.8.0', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-pending', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-yarn', require: false
  gem 'listen'
  gem 'rb-readline', require: false
end

group :development, :test do
  gem 'better_errors', require: false
  gem 'binding_of_caller', require: false
  gem 'factory_bot_rails'
  gem 'haml_lint'
  gem 'pry-byebug'
  gem 'rubocop'
  gem 'spring', require: false
  gem 'umts-custom-cops', require: false
end

group :test do
  gem 'capybara'
  gem 'codeclimate-test-reporter', '~> 1.0'
  gem 'fuubar', require: false
  gem 'rack_session_access'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'timecop'
  gem 'umts-custom-matchers'
end
