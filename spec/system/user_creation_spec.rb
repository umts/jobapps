# frozen_string_literal: true

require 'rails_helper'

describe 'creating a staff member' do
  context 'with admin privilege' do
    before do
      when_current_user_is :admin
      visit staff_dashboard_path
    end

    it 'can be done with a new user' do
      click_on 'Add new staff member'
      click_on 'here'
      expect(page).to have_current_path(new_user_path)
    end

    context 'when creating a new user' do
      before do
        visit new_user_path
      end

      let(:user_fields) { attributes_for(:user).except :staff }

      context 'with required fields filled in' do
        before do
          fill_in_fields_for User, attributes: user_fields
        end

        it 'redirect to the staff dashboard' do
          click_on 'Save changes'
          expect(page).to have_current_path(staff_dashboard_path)
        end

        it 'creates a user' do
          expect { click_on 'Save changes' }.to change(User, :count).by(1)
        end

        it 'informs the user of success' do
          click_on 'Save changes'
          expect(page).to have_text('User successfully created.')
        end
      end

      context 'with a required form element not filled in' do
        it 'renders the new user page' do
          click_on 'Save changes'
          expect(page).to have_current_path(new_user_path)
        end

        it 'does not create a user' do
          expect { click_on 'Save changes' }.not_to change(User, :count)
        end

        it 'has flash errors' do
          click_on 'Save changes'
          expect(page).to have_css('#errors', text: "First name can't be blank")
        end
      end
    end
  end

  context 'with staff privilege' do
    before do
      when_current_user_is :staff
    end

    it 'does not have link for user creation page' do
      visit staff_dashboard_path
      find_link('Add new department')
      expect(page).to have_no_link('Add new staff member')
    end

    it 'does not give access' do
      visit new_user_path
      expect(page).to have_text('You do not have permission to access this page.')
    end
  end
end
