# frozen_string_literal: true

require 'rails_helper'

describe 'deleting users' do
  context 'with admin privilege' do
    before do
      when_current_user_is :admin
      visit edit_user_path(user)
    end

    let!(:user) { create(:user) }

    it 'deletes the user in question' do
      expect { click_on "Remove #{user.full_name}" }
        .to change { User.count }.by(-1)
      expect(User.all).not_to include user
    end

    it 'redirects you to the staff dashboard' do
      click_on "Remove #{user.full_name}"
      expect(page.current_path).to eql staff_dashboard_path
    end

    it 'has a flash message' do
      expect_flash_message(:user_destroy)
      click_on "Remove #{user.full_name}"
    end
  end
end

context 'with staff privilege' do
  before do
    when_current_user_is :staff
  end

  let!(:user) { create(:user) }

  it 'does not have the link' do
    visit staff_dashboard_path
    expect(page).not_to have_link user.proper_name
  end

  it 'does not give access' do
    visit edit_user_path(user)
    expect(page).to have_text 'You do not have permission to access this page.'
  end
end
