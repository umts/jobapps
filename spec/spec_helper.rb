# frozen_string_literal: true

require 'factory_bot_rails'
require 'simplecov'
require 'umts_custom_matchers'

SimpleCov.start 'rails' do
  refuse_coverage_drop if ENV['CI']
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.raise_errors_for_deprecations!

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.example_status_persistence_file_path = File.expand_path File.join(__dir__, 'examples.txt')

  config.order = :random
  Kernel.srand config.seed

  config.before :all do
    FactoryBot.reload
  end

  config.include FactoryBot::Syntax::Methods
  config.include UmtsCustomMatchers

  Dir['./spec/support/**/*.rb'].each { |f| require f }
end
