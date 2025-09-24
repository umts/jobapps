# frozen_string_literal: true

require 'rails_helper'

describe 'deleting a position' do
  subject(:delete) do
    dept_name = position.department.name
    pos_name = position.name
    click_on "Remove #{pos_name} (#{dept_name})"
  end

  let(:position) { create(:position) }

  before do
    when_current_user_is :staff
    visit edit_position_path(position)
  end

  it 'deletes a position' do
    expect { delete }.to change(Position, :count).by(-1)
  end

  it 'deletes the specified position' do
    delete
    expect(Position.ids).not_to include(position.id)
  end

  it 'redirects to the staff dashboard' do
    delete
    expect(page).to have_current_path(staff_dashboard_path)
  end

  it 'renders a positive flash message' do
    delete
    expect(page).to have_text('Position successfully deleted.')
  end
end
