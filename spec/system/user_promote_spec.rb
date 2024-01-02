# frozen_string_literal: true

require 'rails_helper'

describe 'promoting a staff member' do
  context 'with admin privilege' do
    let!(:user) { create(:user) }

    before do
      when_current_user_is :admin
    end

    context 'clicking from dashboard' do
      before do
        visit staff_dashboard_path
      end

      it 'goes to promote user path' do
        click_on 'Add new staff member'
        expect(page.current_path).to eql promote_users_path
      end
    end

    context 'on promote user page' do
      before do
        visit promote_users_path
      end

      context 'field is typed in' do
        it 'promotes the user' do
          text = "#{user.full_name} #{user.spire}"
          fill_in 'promote-search', with: text
          click_on 'Promote'
          flash_message = 'User has been updated.'
          expect(page).to have_text flash_message
        end
      end

      context 'field is left blank' do
        it 'does not promote any user' do
          click_on 'Promote'
          flash_message = 'User has been updated.'
          expect(page).not_to have_text flash_message
        end
      end
    end
  end

  context 'with staff privilege' do
    before do
      when_current_user_is :staff
    end

    let!(:user) { create(:user) }

    it 'does not link to page' do
      visit staff_dashboard_path
      expect(page).not_to have_link 'Add new staff member'
    end

    it 'does not give access' do
      visit promote_users_path
      expected = 'You do not have permission to access this page.'
      expect(page).to have_text expected
    end
  end
end
