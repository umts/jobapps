# frozen_string_literal: true

require 'rails_helper'

describe 'creating departments' do
  before do
    when_current_user_is :staff
    visit new_department_path
  end

  let!(:department_fields) { attributes_for(:department) }

  context 'when name is filled in' do
    before do
      within 'form.new_department' do
        fill_in_fields_for Department, attributes: department_fields
      end
    end

    it 'creates a department' do
      expect { click_on 'Save changes' }.to change(Department, :count).by 1
    end

    it 'uses the provided department attributes' do
      click_on 'Save changes'
      expect(Department.last).to have_attributes(department_fields)
    end

    it 'redirects to the staff dashboard' do
      click_on 'Save changes'
      expect(page).to have_current_path(staff_dashboard_path)
    end

    it 'gives a flash message' do
      click_on 'Save changes'
      expect(page).to have_text('Department successfully created.')
    end
  end

  context 'when name is left blank' do
    it 'does not create the department' do
      expect { click_on 'Save changes' }.not_to change(Department, :count)
    end

    it 'redirects to the new department page' do
      click_on 'Save changes'
      expect(page).to have_current_path(new_department_path)
    end

    it 'gives a flash error' do
      click_on 'Save changes'
      expect(page).to have_css('#errors', text: "Name can't be blank")
    end
  end
end
