# frozen_string_literal: true

source 'https://rubygems.org'
ruby file: '.ruby-version'

gem 'bootstrap', '~> 4.6'
gem 'friendly_id'
gem 'haml'
gem 'haml-rails'
gem 'icalendar'
gem 'matrix'
gem 'mysql2'
gem 'prawn'
gem 'prawn-table'
gem 'puma'
gem 'rails', '~> 7.0.8'
gem 'redcarpet'
gem 'sass-rails'
gem 'snappconfig'
gem 'sprockets-rails'
gem 'uglifier'
gem 'whenever', require: false

group :production do
  gem 'exception_notification'
end

group :development do
  gem 'bcrypt_pbkdf', require: false
  gem 'capistrano', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-pending', require: false
  gem 'capistrano-rails', require: false
  gem 'ed25519', require: false
  gem 'listen'
  gem 'rb-readline', require: false
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :development, :test do
  gem 'better_errors', require: false
  gem 'binding_of_caller', require: false
  gem 'factory_bot_rails'
  gem 'haml_lint'
  gem 'pry-byebug'
  gem 'spring', require: false
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
  gem 'umts-custom-matchers'
end
