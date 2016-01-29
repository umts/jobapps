require 'rails_helper'

describe 'creating new positions' do
  let!(:department) { create :department }
  before :each do
    when_current_user_is :staff, integration: true
    visit new_position_path
  end

  context 'required fields are filled in' do
    before :each do
      within 'form.new_position' do
        fill_in_fields_for Position, attributes: {name: 'Our new shiny position',
          default_interview_location: 'UMTS', department: department}
      end
    end
    it 'creates a new position with the proper attributes' do
      expect { click_on 'Save changes' }.to change { Position.count }.by 1
      expect(Position.last)
        .to have_attributes(name: 'Our new shiny position',
                            default_interview_location: 'UMTS',
                            department: department)
    end
    it 'redirects to the Staff Dashboard' do
      click_on 'Save changes'
      expect(page.current_url).to eql staff_dashboard_url
    end
    it 'renders a flash message' do
      click_on 'Save changes'
      expect(page).to have_selector '#message',
                                    text: 'Position has been created.'
    end
  end

  context 'missing required field' do
    before :each do
      within 'form.new_position' do
        fill_in_fields_for Position, attributes: {name: '', department: department}
      end
    end
    it 'does not add anything' do
      expect { click_on 'Save changes' }.not_to change { Position.count }
    end
    it 'redirects us to the same page' do
      click_on 'Save changes'
      expect(page.current_url).to eql new_position_url
    end
    it 'renders a flash error' do
      click_on 'Save changes'
      expect(page).to have_selector '#errors', text: 'Name can\'t be blank'
    end
  end
end
