require 'rails_helper'

describe 'editing positions' do
  let!(:department) { create :department }
  let!(:base_attributes) do
    { name: 'A position',
      department: department,
      default_interview_location: 'UMTS' }
  end
  let!(:position) { create :position, base_attributes }
  before :each do
    when_current_user_is :staff, integration: true
    visit edit_position_path(position)
  end
  context 'required fields are filled in' do
    before :each do
      within 'form.edit_position' do
        fill_in 'Name', with: 'The name changed!'
      end
    end
    it 'changes the desired field' do
      expect{click_on 'Save changes'}.to change{position.reload.name}
    end
    it 'redirects to the dashboard' do
      click_on 'Save changes'
      expect(page.current_url).to eql staff_dashboard_url
    end
    it 'renders a positive flash message' do
      click_on 'Save changes'
      expect(page).to have_selector '#message',
                                    text: 'Position has been updated'
    end
  end

  context 'required fields are not filled in' do
    before :each do
      within 'form.edit_position' do
        fill_in 'Name', with: ''
      end
    end
    it 'changes nothing' do
      expect{click_on 'Save changes'}.not_to change{position.reload.name}
    end
    it 'redirects to the same page' do
      click_on 'Save changes'
      expect(page.current_url).to eql edit_position_url(position)
    end
    it 'renders a negative flash message' do
      click_on 'Save changes'
      expect(page).to have_selector '#errors', text: 'Name can\'t be blank'
    end
  end
end
