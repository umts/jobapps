# frozen_string_literal: true

require 'rails_helper'

describe 'promoting a staff member' do
  let!(:user) { create(:user) }

  context 'with admin privilege' do
    before { when_current_user_is :admin }

    it 'can be done from the dashboard' do
      visit staff_dashboard_path
      click_on 'Add new staff member'
      expect(page).to have_current_path(promote_users_path)
    end

    context 'when on promote user page' do
      before { visit promote_users_path }

      context 'with the field filled-in' do
        it 'promotes the user' do
          fill_in 'promote-search', with: "#{user.full_name} #{user.spire}"
          click_on 'Promote'
          expect(page).to have_text('User successfully updated.')
        end
      end

      context 'with the field left blank' do
        it 'does not promote any user' do
          click_on 'Promote'
          expect(page).to have_no_text('User successfully updated.')
        end
      end
    end
  end

  context 'with staff privilege' do
    before { when_current_user_is :staff }

    it 'does not link to page' do
      visit staff_dashboard_path
      find_link('Add new department')
      expect(page).to have_no_link('Add new staff member')
    end

    it 'does not give access' do
      visit promote_users_path
      expect(page).to have_text('You do not have permission to access this page.')
    end
  end
end
