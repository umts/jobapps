# frozen_string_literal: true

require 'rails_helper'

describe 'layouts/application.haml' do
  context 'current user is present' do
    before :each do
      user = create :user
      when_current_user_is user
    end
    it 'displays a link to logout' do
      render
      expect(rendered).to have_tag 'a', with: { href: '/sessions/destroy' }
    end
    context 'current user is staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'has a link to the staff dashboard' do
        render
        expect(rendered).to have_tag 'a', with: { href: staff_dashboard_path }
      end
    end
  end
  context 'message present in flash' do
    before :each do
      flash[:message] = 'this is totally a message'
    end
    it 'displays the message' do
      render
      expect(rendered).to have_tag '#message' do
        with_text(/this is totally a message/)
      end
    end
  end
  context 'errors present in flash' do
    before :each do
      flash[:errors] = %w[these are errors]
    end
    it 'displays a list of errors' do
      render
      expect(rendered).to include 'these', 'are', 'errors'
    end
  end
end
