require 'rails_helper'
describe 'subscriptions' do
  let(:position) { create :position }
  context 'subscribing to positions' do
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
  context 'displaying existing subscriptions' do
    let(:user_1) { create :user, :staff }
    let(:user_2) { create :user, :staff }
    let(:subscription) do
      create :subscription,
        user: user_1,
        position: position
    end
    let(:other_position) { create :position }
    before :each do
      when_current_user_is user_2, integration: true
      visit edit_position_path(position)
    end
    it 'does not display subscription belonging to another user' do
      expect(page).not_to have_text subscription.email
    end
    it 'only displays emails that have been subscribed to this position' do
      visit edit_position_path(other_position)
      expect(page).not_to have_text subscription.email
    end
  end
  context 'deleting a subscription' do
    let(:user) { create :user, :staff }
    let(:subscription) do
      create :subscription, user: user, position: position
    end
    before :each do
      when_current_user_is user, integration: true
      visit edit_position_path(position)
    end
    it 'removes the email from the page when remove is clicked' do
     click_button 'Remove'
     expect(page).not_to have_text subscription.email
    end
  end
end
