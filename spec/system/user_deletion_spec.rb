# frozen_string_literal: true

require 'rails_helper'

describe 'deleting users' do
  context 'with admin privilege' do
    subject(:submit) { click_on "Remove #{user.full_name}" }

    before do
      when_current_user_is :admin
      visit edit_user_path(user)
    end

    let!(:user) { create(:user) }

    it 'deletes a user' do
      expect { submit }.to change(User, :count).by(-1)
    end

    it 'deletes the user in question' do
      submit
      expect(User.ids).not_to include(user.id)
    end

    it 'redirects to the staff dashboard' do
      submit
      expect(page).to have_current_path(staff_dashboard_path)
    end

    it 'has a flash message' do
      submit
      expect(page).to have_text('User successfully deleted.')
    end
  end
end
