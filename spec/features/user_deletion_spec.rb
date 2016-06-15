require 'rails_helper'

describe 'deleting users' do
  context 'with admin privilege' do
    before :each do
      when_current_user_is :admin, integration: true
      @user = create :user
      visit edit_user_path(@user)
    end

    it 'deletes the user in question' do
      expect { click_on "Remove #{@user.full_name}" }
        .to change { User.count }.by(-1)
      expect(User.all).not_to include @user
    end

    it 'redirects you to the staff dashboard' do
      click_on "Remove #{@user.full_name}"
      expect(page.current_url).to eql staff_dashboard_url
    end

    it 'has a flash message' do
      expect_flash_message(:user_destroy)
      click_on "Remove #{@user.full_name}"
    end
  end
end

context 'with staff privilege' do 
  before :each do 
    when_current_user_is :staff, integration: true
    @user = create :user
  end
  context 'from dashboard' do 
    before :each do 
      visit staff_dashboard_url
    end
    it 'does not have the link' do 
      expect(page).not_to have_link "#{@user.last_name}, #{@user.first_name}"
    end
  end
  context 'from edit page' do 
    before :each do 
      visit edit_user_path(@user)
    end
    it 'does not delete the user in question' do 
      expect { click_on "Remove #{@user.full_name}" }
        .not_to change { User.count }
      expect(page).to have_text 'You do not have permission to access this page.'
      expect(User.all).to include @user
    end
  end
end
