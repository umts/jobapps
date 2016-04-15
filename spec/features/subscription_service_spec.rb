require 'rails_helper'
describe 'Subscriptions' do
  let(:position) { create :position }
  context 'Subscribing to positions' do
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
  context 'Displaying existing subscriptions' do
    let(:user_1) { create :user, :staff }
    let(:user_2) { create :user, :staff }
    let(:subscription) do
      create :subscription,
        user: user_1,
        email: 'subscriber@email.com',
        position: position
    end
    before :each do
      when_current_user_is user_2, integration: true
      visit edit_position_path(position)
    end
    it 'does not display subscription belonging to other user' do
      expect(page).not_to have_text subscription.email
    end
  end
end
