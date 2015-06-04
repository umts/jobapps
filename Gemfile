source 'https://rubygems.org'

# Rubocop for extra yelling-at-us-ness
gem 'rubocop', require: false
# I like HAML
gem 'haml'
# Snappconfig for configuration storage
gem 'snappconfig'
# Markdown parsing with Redcardpet
gem 'redcarpet'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.2'
# Use mysql as the database for Active Record
gem 'mysql'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Include jqueryUI.
gem 'jquery-ui-rails'
# jQuery date/time picker
gem 'jquery-datetimepicker-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application
# running in the background.
# Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

group :development do
  # better_errors and binding_of_caller for in-browser debugging
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  # pry for inline debugging
  gem 'pry-byebug'
end

group :test do
  gem 'codeclimate-test-reporter', require: false
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'simplecov', '>= 0.9'
  gem 'mocha'
  gem 'timecop'
end
