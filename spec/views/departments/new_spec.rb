require 'rails_helper'
include RSpecHtmlMatchers

describe 'departments/new.haml' do
  before :each do
    @department = create :department
  end
  it 'contains a form to create a new department' do
    render
    action_path = departments_path
    expect(rendered).to have_form action_path, :post do
      with_text_field 'department[name]'
    end
  end
end
