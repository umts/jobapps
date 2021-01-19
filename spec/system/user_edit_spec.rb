# frozen_string_literal: true

require 'rails_helper'

describe 'edit staff users' do
  context 'with admin privilege' do
    let!(:user) { create :user, staff: true }

    context 'clicking from dashboard' do
      before :each do
        when_current_user_is :admin, system: true
        visit staff_dashboard_path
      end
      it 'directs to the correct page' do
        click_link user.proper_name, href: edit_user_path(user)
        expect(page.current_path).to eql edit_user_path(user)
      end
    end

    context 'on edit user page' do
      before :each do
        when_current_user_is :admin, system: true
        visit edit_user_path(user)
      end

      context 'every field is filled in correctly' do
        let!(:attributes) { attributes_for(:user).except :staff, :last_name }
        # staff attribute is hidden field, and don't want to change last name
        before :each do
          within 'form.edit_user' do
            fill_in_fields_for User,
                               attributes: attributes
                                 .merge(first_name: 'Bananas')
          end
        end

        it 'only changes the given attributes' do
          click_on 'Save changes'
          initial_last_name = user.last_name
          expect(user.reload)
            .to have_attributes first_name: 'Bananas',
                                last_name: initial_last_name
        end

        it 'redirects you to the staff dashboard' do
          click_on 'Save changes'
          expect(page.current_path).to eql staff_dashboard_path
        end

        it 'gives a flash message' do
          expect_flash_message(:user_update)
          click_on 'Save changes'
        end
      end

      context 'a field is left blank' do
        let!(:attributes) { attributes_for(:user).except :staff }
        before :each do
          within 'form.edit_user' do
            fill_in_fields_for User, attributes: attributes
              .merge(first_name: '')
          end
        end

        it 'does not change the blank attribute' do
          click_on 'Save changes'
          expect(user.reload.attributes.symbolize_keys)
            .to include first_name: user.first_name, last_name: user.last_name
        end

        it 'redirects back to the edit user page' do
          click_on 'Save changes'
          expect(page.current_path).to eql edit_user_path(user)
        end

        it 'has flash errors' do
          click_on 'Save changes'
          expect(page).to have_selector '#errors',
                                        text: "First name can't be blank"
        end
      end
    end
  end
  context 'with staff privilege' do
    before :each do
      when_current_user_is :staff, system: true
    end
    let!(:user) { create :user }
    it 'does not have link to page' do
      visit staff_dashboard_path
      expect(page).not_to have_link user.proper_name
    end
    it 'does not give access' do
      visit edit_user_path(user)
      expected = 'You do not have permission to access this page.'
      expect(page).to have_text expected
    end
  end
end
