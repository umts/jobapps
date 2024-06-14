# frozen_string_literal: true

require 'rails_helper'

describe 'creating new positions' do
  let!(:department) { create(:department) }

  before do
    when_current_user_is :staff
    visit new_position_path
  end

  context 'required fields are filled in' do
    before do
      within 'form.new_position' do
        fill_in_fields_for Position, attributes:
        { name: 'Our new shiny position',
          default_interview_location: 'UMTS',
          department: }
      end
    end

    it 'creates a new position with the proper attributes' do
      expect { click_on 'Save changes' }.to change(Position, :count).by 1
      expect(Position.last)
        .to have_attributes(name: 'Our new shiny position',
                            default_interview_location: 'UMTS',
                            department:)
    end

    it 'redirects to the Staff Dashboard' do
      click_on 'Save changes'
      expect(page.current_path).to eql staff_dashboard_path
    end

    it 'renders a flash message' do
      click_on 'Save changes'
      expect(page).to have_text('Position successfully created.')
    end
  end

  context 'missing required field' do
    before do
      within 'form.new_position' do
        fill_in_fields_for Position,
                           attributes: { name: '', department: }
      end
    end

    it 'does not add anything' do
      expect { click_on 'Save changes' }.not_to change(Position, :count)
    end

    it 'redirects us to the same page' do
      click_on 'Save changes'
      expect(page.current_path).to eql new_position_path
    end

    it 'renders a flash error' do
      click_on 'Save changes'
      expect(page).to have_css '#errors', text: 'Name can\'t be blank'
    end
  end
end
