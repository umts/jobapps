require 'rails_helper'
describe 'Subscribing to positions' do
  let(:position) { create :position }
  before :each do
    when_current_user_is :staff, integration: true
    visit edit_position_path(position)
  end
  it 'displays the email address when subscribe is clicked' do
    fill_in 'Email', with: 'jobapps@transit.com'
    click_button 'Subscribe'
    expect(page).to have_text('jobapps@transit.com')
  end
end
