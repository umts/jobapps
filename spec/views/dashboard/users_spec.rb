require 'rails_helper'
include RSpecHtmlMatchers

describe 'dashboard/_users.haml' do
  before :each do
    @user = create :user, staff: true
    assign :staff, Array(@user)
  end
  it 'includes a link to add a new staff member' do
    render
    expect(rendered).to have_tag 'a', with: { href: new_user_path }
  end
  it 'includes links to edit and remove existing staff members' do
    render
    action_path = edit_user_path @user
    expect(rendered).to have_tag 'a', with: { href: action_path }
  end
end
