# frozen_string_literal: true

require 'factory_bot_rails'
require 'simplecov'
require 'umts_custom_matchers'

SimpleCov.start 'rails' do
  refuse_coverage_drop
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.default_formatter = 'doc' if config.files_to_run.one?

  config.before :all do
    FactoryBot.reload
  end

  config.include FactoryBot::Syntax::Methods
  config.include UmtsCustomMatchers

  Dir['./spec/support/**/*.rb'].each { |f| require f }
end
