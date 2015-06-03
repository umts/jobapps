require 'codeclimate-test-reporter'
require 'factory_girl_rails'
require 'simplecov'

CodeClimate::TestReporter.start if ENV['CI']
SimpleCov.start 'rails'
SimpleCov.start do
  add_filter '/config/'
  add_filter '/spec/'
end

RSpec.configure do |config|
  config.before :all do
    FactoryGirl.reload
  end
  config.include FactoryGirl::Syntax::Methods
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

#controller spec helper methods


#attributes_for but including foreign key associations
#adapted from https://github.com/thoughtbot/factory_girl/issues/359#issuecomment-21418209
def attributes_with_foreign_keys_for *args
  build(*args).attributes.delete_if do |k, v|
    %w(id created_at updated_at).include? k
  end
end

#TODO: write a custom matcher?
def expect_redirect_to_back path = 'http://test.host/redirect',  &block
  request.env['HTTP_REFERER'] = path
  yield
  expect(response).to have_http_status :redirect
  expect(response).to redirect_to path
end

def set_current_user_to user
  session[:user_id] = case user
  when :staff
    (create :user, staff: true).id
  when :student
    (create :user, staff: false).id
  when User
    user.id
  else raise ArgumentError, 'Invalid user type'
  end
end


