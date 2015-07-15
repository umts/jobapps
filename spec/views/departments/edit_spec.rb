require 'rails_helper'
include RSpecHtmlMatchers

describe 'departments/edit.haml' do
  before :each do
    @department = create :department
  end
  it 'contains a form to edit the department' do
    render
    action_path = department_path @department
    expect(rendered).to have_form action_path, :post do
      with_tag 'input', with: { name: '_method', value: 'patch' }
    end
  end
  it 'contains a button to remove the department' do
    render
    action_path = department_path @department
    expect(rendered).to have_form action_path, :post do
      with_tag 'input', with: { name: '_method', value: 'delete' }
    end
  end
end
