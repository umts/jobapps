source 'https://rubygems.org'

# Rubocop for extra yelling-at-us-ness
gem 'rubocop', require: false
# I like HAML
gem 'haml'
# HAML linter
gem 'haml-lint'
# Snappconfig for configuration storage
gem 'snappconfig'
# Markdown parsing with Redcardpet
gem 'redcarpet'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'
# Use mysql as the database for Active Record
gem 'mysql'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Include jqueryUI.
gem 'jquery-ui-rails'
# jQuery date/time picker
gem 'jquery-datetimepicker-rails'

# Spring speeds up development by keeping your application
# running in the background.
# Read more: https://github.com/rails/spring
gem 'spring',        group: :development

group :development do
  # better_errors and binding_of_caller for in-browser debugging
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  # pry for inline debugging
  gem 'pry-byebug'
end

group :production do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'
  # Notify us of things gone terribly, horribly wrong
  gem 'exception_notification'
end

group :test do
  gem 'codeclimate-test-reporter', require: false
  gem 'rspec-rails'
  gem 'rspec-html-matchers'
  gem 'factory_girl_rails'
  gem 'simplecov'
  gem 'mocha'
  gem 'timecop'
end
