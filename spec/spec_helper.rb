# frozen_string_literal: true

require 'factory_bot_rails'
require 'simplecov'
require 'umts-custom-matchers'

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

# controller spec helper methods

# Expects that the controller action called after this is invoked
# will call show_message with the symbol given, and a hash
# containing a default.
def expect_flash_message(name)
  expect_any_instance_of(ConfigurableMessages)
    .to receive(:show_message)
    .with(name, hash_including(:default))
end

# Using the human attribute names for the given AR model
# and the hash of attributes from the keyword argument,
# fills in form elements with the provided attributes
def fill_in_fields_for(model, attributes:)
  attributes.each do |attribute, value|
    name = model.human_attribute_name attribute
    value = value.name if value.respond_to? :name
    if page.has_selector? :fillable_field, name then fill_in name, with: value
    elsif page.has_selector? :select, name then select value, from: name
    else raise Capybara::ElementNotFound, "Unable to find field #{name}"
    end
  end
end

# Sets current user based on two acceptable values:
# 1. a symbol name of a user factory trait;
# 2. a specific instance of User.
def when_current_user_is(user, options = {})
  current_user =
    case user
    when Symbol then create :user, user
    when User then user
    when nil then nil
    else raise ArgumentError, 'Invalid user type'
    end
  set_current_user current_user, options
end

private

# Helper method, sets the current user based on any
# options defined (mostly spec type)
def set_current_user(user, **options)
  if options.key? :view
    assign :current_user, user
  elsif options.key? :integration
    page.set_rack_session user_id: user.try(:id)
  elsif user.present?
    session[:user_id] = user.id
  else session[:spire] = build(:user).spire
  end
end
