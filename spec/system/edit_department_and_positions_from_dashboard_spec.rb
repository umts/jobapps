# frozen_string_literal: true

require 'rails_helper'

describe 'adding or editing departments and positions from dashboard' do
  let!(:department) { create(:department) }
  let!(:position) { create(:position, department:) }
  before :each do
    when_current_user_is :staff
    visit staff_dashboard_path
  end
  it 'has a link to edit the department name' do
    click_link 'Change department name',
               href: edit_department_path(department)
    expect(page.current_path).to eql edit_department_path(department)
  end
  it 'has a link to edit the positions' do
    click_link "Edit #{position.name} position",
               href: edit_position_path(position)
    expect(page.current_path).to eql edit_position_path(position)
  end
  it 'has a link to add a new position' do
    click_link 'Add new position', href: new_position_path
    expect(page.current_path).to eql new_position_path
  end
  it 'has a link to add a new department' do
    click_link 'Add new department', href: new_department_path
    expect(page.current_path).to eql new_department_path
  end
end
