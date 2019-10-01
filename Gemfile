# frozen_string_literal: true

source 'https://rubygems.org'
ruby IO.read(File.expand_path('.ruby-version', __dir__)).strip

gem 'bootstrap', '~> 4.0'
gem 'coffee-rails'
gem 'factory_bot_rails'
gem 'friendly_id', '~> 5.1.0'
gem 'haml'
gem 'haml-rails'
gem 'jquery-datatables-rails'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'mysql2'
gem 'prawn'
gem 'prawn-table'
gem 'rails', '~> 5.2.0'
gem 'rails-controller-testing'
gem 'redcarpet'
gem 'sass-rails'
gem 'snappconfig'
gem 'strscan'
gem 'uglifier'
gem 'whenever', require: false

source 'https://rails-assets.org' do
  gem 'rails-assets-jquery.maskedinput'
  gem 'rails-assets-wenzhixin--multiple-select'
end

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
  gem 'rb-readline', require: false
end

group :development, :test do
  gem 'better_errors', require: false
  gem 'binding_of_caller', require: false
  gem 'capybara'
  gem 'codeclimate-test-reporter', '~> 1.0'
  gem 'fuubar', require: false
  gem 'guard-rspec', require: false
  gem 'haml_lint'
  gem 'mocha'
  gem 'pry-byebug'
  gem 'rack_session_access'
  gem 'rspec-html-matchers'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'simplecov'
  gem 'spring', require: false
  gem 'timecop'
  gem 'umts-custom-cops', require: false
  gem 'umts-custom-matchers'
end
