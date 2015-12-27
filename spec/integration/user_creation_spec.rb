require 'rails_helper'

describe 'creating users', type: :feature do
  before :each do
    when_current_user_is :staff, integration: true
    visit new_user_path
  end
  let(:attrs) { attributes_for :user }

  context 'with required form elements filled in' do
    before :each do
      within('form.new_user') do
        fill_in 'First name', with: attrs[:first_name]
        fill_in 'Last name', with: attrs[:last_name]
        fill_in 'Email', with: attrs[:email]
        fill_in 'SPIRE', with: attrs[:spire]
      end
    end
    it 'renders the staff dashboard' do
      click_on 'Save changes'
      expect(page.current_url).to eql staff_dashboard_url
    end
    it 'creates a user' do
      expect { click_on 'Save changes' }
        .to change { User.count }.by 1
    end
    it 'has a flash message' do
      click_on 'Save changes'
      expect(page).to have_selector '#message'
      expect(page).to have_content 'User has been created.'
    end
  end

  context 'with a required form element not filled in' do
    it 'renders the new user page' do
      click_on 'Save changes'
      expect(page.current_url).to eql new_user_url
    end
    it 'does not create a user' do
      expect { click_on 'Save changes' }
        .not_to change { User.count }
    end
    it 'has flash errors' do
      click_on 'Save changes'
      expect(page).to have_selector '#errors'
      expect(page).to have_content "First name can't be blank"
    end
  end
end
