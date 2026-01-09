# frozen_string_literal: true

source 'https://rubygems.org'
ruby file: '.ruby-version'

gem 'cssbundling-rails'
gem 'csv'
gem 'friendly_id'
gem 'haml'
gem 'haml-rails'
gem 'icalendar'
gem 'irb'
# TODO: Remove ruby platform when we're off RHEL 7
gem 'nokogiri', force_ruby_platform: true
gem 'prawn'
gem 'prawn-table'
gem 'puma'
gem 'rails', '~> 8.1.2'
gem 'redcarpet'
gem 'snappconfig'
gem 'sprockets-rails'
gem 'terser'
gem 'trilogy'
gem 'whenever', require: false

group :production do
  gem 'exception_notification'
end

group :development do
  gem 'bcrypt_pbkdf', require: false
  gem 'brakeman', require: false
  gem 'capistrano', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-pending', require: false
  gem 'capistrano-rails', require: false
  gem 'ed25519', require: false
  gem 'listen'
  gem 'overcommit', require: false
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
end

group :development, :test do
  gem 'better_errors', require: false
  gem 'binding_of_caller', require: false
  gem 'debug'
  gem 'factory_bot_rails'
  gem 'haml_lint'
end

group :test do
  gem 'capybara'
  gem 'rack_session_access'
  gem 'rails-controller-testing'
  gem 'rspec-html-matchers'
  gem 'rspec-rails'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'timecop'
end
