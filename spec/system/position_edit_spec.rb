# frozen_string_literal: true

require 'rails_helper'

describe 'editing positions' do
  let!(:department) { create :department }
  let!(:base_attributes) do
    { name: 'A position',
      department: department,
      default_interview_location: 'UMTS' }
  end
  let!(:position) { create :position, base_attributes }
  let(:save) { click_on 'Save changes' }
  before :each do
    when_current_user_is :staff
    visit edit_position_path(position)
  end
  context 'required fields are filled in' do
    before :each do
      within 'form.edit_position' do
        fill_in_fields_for Position, attributes: { name: 'The name changed!' }
      end
    end
    it 'changes the desired field' do
      expect { save }.to change { position.reload.name }
    end
    it 'redirects to the dashboard' do
      save
      expect(page.current_path).to eql staff_dashboard_path
    end
    it 'renders a positive flash message' do
      expect_flash_message(:position_update)
      save
    end
  end

  context 'required fields are not filled in' do
    before :each do
      within 'form.edit_position' do
        fill_in_fields_for Position, attributes: { name: '' }
      end
    end
    it 'changes nothing' do
      expect { save }.not_to change { position.reload.name }
    end
    it 'redirects to the same page' do
      save
      expect(page.current_path).to eql edit_position_path(position)
    end
    it 'renders a negative flash message' do
      save
      expect(page).to have_selector '#errors', text: "Name can't be blank"
    end
  end
end
