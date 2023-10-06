# frozen_string_literal: true

source 'https://rubygems.org'
ruby IO.read(File.expand_path('.ruby-version', __dir__)).strip

gem 'bootstrap', '~> 4.0'
gem 'friendly_id', '~> 5.1'
gem 'haml'
gem 'haml-rails'
gem 'icalendar'
gem 'mysql2'
gem 'prawn'
gem 'prawn-table'
gem 'rails', '~> 6.1.3'

gem 'puma'
gem 'redcarpet'
gem 'sass-rails'
gem 'snappconfig'
gem 'uglifier'
gem 'whenever', require: false

group :production do
  gem 'exception_notification'
end

group :development do
  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0', require: false
  gem 'capistrano', '~> 3.14', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-passenger', require: false
  gem 'capistrano-pending', require: false
  gem 'capistrano-rails', require: false
  gem 'ed25519', '>= 1.2', '< 2.0', require: false
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
  gem 'simplecov'
  gem 'timecop'
  gem 'umts-custom-matchers'
  gem 'webdrivers'
end
