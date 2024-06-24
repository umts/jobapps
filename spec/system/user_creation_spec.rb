# frozen_string_literal: true

require 'rails_helper'

describe 'creating a staff member' do
  context 'with admin privilege' do
    before do
      when_current_user_is :admin
    end

    context 'clicking from dashboard' do
      before do
        visit staff_dashboard_path
      end

      it 'goes to the new user page' do
        click_on 'Add new staff member'
        click_on 'here'
        expect(page.current_path).to eql new_user_path
      end
    end

    context 'on user creation page' do
      before do
        visit new_user_path
      end

      let!(:user_fields) { attributes_for(:user).except :staff }

      # staff attribute is a hidden field in the form
      # so no need to fill it in
      context 'with required fields filled in' do
        before do
          within 'form.new_user' do
            fill_in_fields_for User, attributes: user_fields
          end
        end

        it 'renders the staff dashboard' do
          click_on 'Save changes'
          expect(page.current_path).to eql staff_dashboard_path
        end

        it 'creates a user' do
          expect { click_on 'Save changes' }
            .to change(User, :count).by 1
        end

        it 'has a flash message' do
          click_on 'Save changes'
          expect(page).to have_text('User successfully created.')
        end
      end

      context 'with a required form element not filled in' do
        it 'renders the new user page' do
          click_on 'Save changes'
          expect(page.current_path).to eql new_user_path
        end

        it 'does not create a user' do
          expect { click_on 'Save changes' }
            .not_to change(User, :count)
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
      expect(page).to have_no_link 'Add new staff member'
    end

    it 'does not give access' do
      visit new_user_path
      expected = 'You do not have permission to access this page.'
      expect(page).to have_text expected
    end
  end
end
