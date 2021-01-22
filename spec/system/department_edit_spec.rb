# frozen_string_literal: true

require 'rails_helper'

describe 'editing departments' do
  let(:base_attributes) { { name: 'Bananas' } }
  let(:dept) { create :department, base_attributes }

  before :each do
    when_current_user_is :staff
    visit edit_department_path(dept)
  end

  context 'all fields filled in' do
    before :each do
      within 'form.edit_department' do
        fill_in_fields_for Department, attributes: base_attributes
          .merge(name: 'Apples')
      end
    end

    it 'changes the given field' do
      click_on 'Save changes'
      expect(dept.reload.name).to eql 'Apples'
    end

    it 'redirects to the staff dashboard' do
      click_on 'Save changes'
      expect(page.current_path).to eql staff_dashboard_path
    end

    it 'gives a flash message' do
      expect_flash_message(:department_update)
      click_on 'Save changes'
    end
  end

  context 'field left blank' do
    before :each do
      within 'form.edit_department' do
        fill_in_fields_for Department, attributes: base_attributes
          .merge(name: '')
      end
    end

    it 'does not change the given field' do
      click_on 'Save changes'
      expect(dept.reload.name).to eql 'Bananas'
    end

    it 'redirects back to same page' do
      click_on 'Save changes'
      expect(page.current_path).to eql edit_department_path(dept)
    end

    it 'gives a flash error' do
      click_on 'Save changes'
      expect(page).to have_selector '#errors', text: "Name can't be blank"
    end
  end
end
