require 'rails_helper'

describe 'edit staff users' do
  let!(:user) { create :user, staff: true, last_name: 'Smith' }

  context 'clicking from dashboard' do
    before :each do
      when_current_user_is :staff, integration: true
      visit staff_dashboard_url
    end
    it 'directs to the correct page' do
      click_link user.proper_name.to_s, href: edit_user_path(user)
      expect(page.current_url).to eql edit_user_url(user)
    end
  end

  context 'on edit user page' do
    before :each do
      when_current_user_is :staff, integration: true
      visit edit_user_url(user)
    end

    context 'every field is filled in correctly' do
      let!(:attributes) { attributes_for(:user).except :staff, :last_name }
      # staff attribute is hidden field, and don't want to change last name
      before :each do
        within 'form.edit_user' do
          fill_in_fields_for User, attributes: attributes
            .merge(first_name: 'Bananas')
        end
      end

      it 'only changes the given attributes' do
        click_on 'Save changes'
        expect(user.reload.attributes.symbolize_keys)
          .to include first_name: 'Bananas', last_name: 'Smith'
      end

      it 'redirects you to the staff dashboard' do
        click_on 'Save changes'
        expect(page.current_url).to eql staff_dashboard_url
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
        expect(page.current_url).to eql edit_user_url(user)
      end

      it 'has flash errors' do
        click_on 'Save changes'
        expect(page).to have_selector '#errors',
                                      text: "First name can't be blank"
      end
    end
  end
end
