require 'rails_helper'
include RSpecHtmlMatchers

describe 'users/edit.haml' do
  before :each do
    @user = create :user
  end
  it 'contains a form to edit the user' do
    render
    action_path = user_path @user
    expect(rendered).to have_form action_path, :post do
      with_tag 'input', with: { name: '_method', value: 'patch' }
    end
  end
  it 'contains a button to delete the user' do
    render
    action_path = user_path @user
    expect(rendered).to have_form action_path, :post do
      with_tag 'input', with: { name: '_method', value: 'delete' }
    end
  end
end
