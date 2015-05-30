require 'factory_girl_rails'
require 'simplecov'

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

#TODO: write a custom matcher?
def expect_redirect_to_back path = 'http://text.example.com/redirect',  &block
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
  end
end


