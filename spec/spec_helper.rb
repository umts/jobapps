require 'codeclimate-test-reporter'
require 'factory_girl_rails'
require 'simplecov'
require 'umts-custom-matchers'

CodeClimate::TestReporter.start if ENV['CI']
SimpleCov.start 'rails' do
  refuse_coverage_drop
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.before :all do
    FactoryGirl.reload
  end
  config.include FactoryGirl::Syntax::Methods
  config.include UmtsCustomMatchers
end

# controller spec helper methods

# attributes_for but including foreign key associations
# adapted from https://github.com/thoughtbot/factory_girl/issues/359#issuecomment-21418209
def attributes_with_foreign_keys_for(*args)
  build(*args).attributes.delete_if do |k, _v|
    %w(id created_at updated_at).include? k
  end
end

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
    fill_in model.human_attribute_name(attribute), with: value
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
