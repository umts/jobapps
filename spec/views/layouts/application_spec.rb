require 'rails_helper'
include RSpecHtmlMatchers

describe 'layouts/application.haml' do
  context 'current user is present' do
    before :each do
      when_current_user_is(create :user, view: true)
    end
    context 'current user is staff' do
      before :each do
        when_current_user_is :staff, view: true
      end
    end
  end
  context 'message present in flash' do
  end
  context 'errors present in flash' do
  end
end
