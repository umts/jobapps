require 'rails_helper'

describe 'deleting a position' do
  let!(:department) { create :department }
  let!(:base_attributes) do
    { name: 'A position',
      department: department,
      default_interview_location: 'UMTS' }
  end
  let!(:position) { create :position, base_attributes }
  let(:delete) {click_on "Remove #{position.name} (#{position.department.name})"}
  before :each do
    when_current_user_is :staff, integration: true
    visit edit_position_path(position)
  end
  it 'deletes the position in question' do
    expect { delete }
      .to change { Position.count }.by(-1)
    expect(Position.all).not_to include position
  end
  it 'redirects to the staff dashboard' do
    delete
    expect(page.current_url).to eql staff_dashboard_url
  end
  it 'renders a positive flash message' do
    delete
    expect(page).to have_selector '#message', text: 'Position has been deleted.'
  end
end
