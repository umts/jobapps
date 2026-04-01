# frozen_string_literal: true

require 'rails_helper'

describe 'editing staff users' do
  context 'with admin privilege' do
    let!(:user) { create(:user, staff: true) }

    before { when_current_user_is :admin }

    it 'is available from the dashboard' do
      visit staff_dashboard_path
      expect(page).to have_link user.proper_name, href: edit_user_path(user)
    end

    context 'when on edit user page' do
      subject(:submit) { click_on 'Save changes' }

      before do
        visit edit_user_path(user)
      end

      context 'when every field is filled in correctly' do
        let(:attributes) { attributes_for(:user).except :staff, :last_name }

        before do
          fill_in_fields_for User, attributes: attributes.merge(first_name: 'Bananas')
        end

        it 'changes the given attributes' do
          expect { submit }.to change { user.reload.first_name }.to('Bananas')
        end

        it 'redirects you to the staff dashboard' do
          submit
          expect(page).to have_current_path(staff_dashboard_path)
        end

        it 'gives a flash message' do
          submit
          expect(page).to have_text('User successfully updated.')
        end
      end

      context 'when a required field is left blank' do
        let(:attributes) { attributes_for(:user).except(:staff) }

        before do
          fill_in_fields_for User, attributes: attributes.merge(first_name: '')
        end

        it 'does not change the blank attribute' do
          expect { submit }.not_to(change { user.reload.first_name })
        end

        it 'redirects back to the edit user page' do
          submit
          expect(page).to have_current_path(edit_user_path(user))
        end

        it 'has flash errors' do
          submit
          expect(page).to have_css('#errors', text: "First name can't be blank")
        end
      end
    end
  end

  context 'with staff privilege' do
    before { when_current_user_is :staff }

    let!(:user) { create(:user) }

    it 'does not have link to page' do
      visit staff_dashboard_path
      find_link('Add new department')
      expect(page).to have_no_link(user.proper_name)
    end

    it 'does not give access' do
      visit edit_user_path(user)
      expect(page).to have_text('You do not have permission to access this page.')
    end
  end
end
