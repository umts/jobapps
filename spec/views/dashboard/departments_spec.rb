require 'rails_helper'
include RSpecHtmlMatchers

describe 'dashboard/_departments.haml' do
  before :each do
    @department = create :department
    assign :departments, Array(@department)
    @position = create :position, department: @department
    assign :positions, Array(@position)
  end
  it 'includes a link to edit the department name' do
    render
    action_path = edit_department_path @department
    expect(rendered).to have_tag 'a', with: { href: action_path }
  end
  it 'includes a link to edit the positions' do
    render
    action_path = edit_position_path @position
    expect(rendered).to have_tag 'a', with: { href: action_path }
  end
  it 'includes a link to add a new position' do
    render
    expect(rendered).to have_tag 'a', with: { href: new_position_path }
  end
  it 'includes a link to add a new department' do
    render
    expect(rendered).to have_tag 'a', with: { href: new_department_path }
  end
end
