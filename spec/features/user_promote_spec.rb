require 'rails_helper'

describe 'promoting a staff member' do
  context 'with admin privilege' do
    let!(:user) { create :user }
    before :each do
      when_current_user_is :admin, integration: true
    end
    context 'clicking from dashboard' do
      before :each do
        visit staff_dashboard_url
      end
      it 'goes to promote user url' do
        click_on 'Add new staff member'
        expect(page.current_url).to eql promote_users_url
      end
    end
    context 'on promote user page' do
      before :each do
        visit promote_users_url
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
    before :each do
      when_current_user_is :staff, integration: true
    end
    let!(:user) { create :user }
    it 'does not link to page' do
      visit staff_dashboard_url
      expect(page).not_to have_link 'Add new staff member'
    end
    it 'does not give access' do
      visit promote_users_url
      expected = 'You do not have permission to access this page.'
      expect(page).to have_text expected
    end
  end
end
