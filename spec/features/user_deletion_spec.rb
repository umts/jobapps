require 'rails_helper'

describe 'deleting users' do
  before :each do
    when_current_user_is :staff, integration: true
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
