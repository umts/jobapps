# frozen_string_literal: true

require 'rails_helper'

describe 'deleting users' do
  subject(:submit) { click_on "Remove #{dept.name}" }

  let(:dept) { create(:department) }

  before do
    when_current_user_is :staff
    visit edit_department_path(dept)
  end

  it 'deletes a department' do
    expect { submit }.to change(Department, :count).by(-1)
  end

  it 'deletes the department in question' do
    submit
    expect(Department.ids).not_to include(dept.id)
  end

  it 'redirects you to the staff dashboard' do
    submit
    expect(page).to have_current_path(staff_dashboard_path)
  end

  it 'gives a flash message' do
    submit
    expect(page).to have_text('Department successfully deleted.')
  end
end
