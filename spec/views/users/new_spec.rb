require 'rails_helper'
include RSpecHtmlMatchers

describe 'users/new' do
  before :each do
    @user = create :user
  end
  it 'contains a form to create a new user' do
    render
    action_path = users_path
    expect(rendered).to have_form action_path, :post do
      with_tag 'input', with: { name: 'user[first_name]' }
      with_tag 'input', with: { name: 'user[last_name]' }
      with_tag 'input', with: { name: 'user[email]' }
      with_tag 'input', with: { name: 'user[spire]' }
    end
  end
end
