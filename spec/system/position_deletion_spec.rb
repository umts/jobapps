# frozen_string_literal: true

require 'rails_helper'

describe 'deleting a position' do
  let!(:department) { create :department }
  let!(:base_attributes) do
    { name: 'A position',
      department: department,
      default_interview_location: 'UMTS' }
  end
  let!(:position) { create :position, base_attributes }
  let(:delete) do
    dept_name = position.department.name
    pos_name = position.name
    click_on "Remove #{pos_name} (#{dept_name})"
  end
  before :each do
    when_current_user_is :staff
    visit edit_position_path(position)
  end
  it 'deletes the position in question' do
    expect { delete }
      .to change { Position.count }.by(-1)
    expect(Position.all).not_to include position
  end
  it 'redirects to the staff dashboard' do
    delete
    expect(page.current_path).to eql staff_dashboard_path
  end
  it 'renders a positive flash message' do
    expect_flash_message(:position_destroy)
    delete
  end
end
