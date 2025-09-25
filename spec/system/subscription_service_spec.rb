# frozen_string_literal: true

require 'rails_helper'

describe 'subscriptions' do
  let(:position) { create(:position) }

  describe 'subscribing to positions' do
    before do
      when_current_user_is :staff
      visit edit_position_path(position)
    end

    it 'displays the email address when subscribe is clicked' do
      fill_in 'Email', with: 'jobapps@transit.com'
      click_button 'Subscribe'
      expect(page).to have_text('jobapps@transit.com')
    end
  end

  describe 'displaying existing subscriptions' do
    let(:subscription_user) { create(:user, :staff) }
    let(:other_user) { create(:user, :staff) }

    let(:subscription) do
      create(:subscription, user: subscription_user, position:)
    end
    let(:other_position) { create(:position) }

    it 'does not display subscription belonging to another user' do
      when_current_user_is other_user
      visit edit_position_path(position)
      find_button('Subscribe')
      expect(page).to have_no_text(subscription.email)
    end

    it 'only displays emails that have been subscribed to this position' do
      when_current_user_is subscription_user
      visit edit_position_path(other_position)
      find_button('Subscribe')
      expect(page).to have_no_text(subscription.email)
    end
  end

  describe 'deleting a subscription' do
    let(:user) { create(:user, :staff) }
    let!(:subscription) { create(:subscription, user:, position:) }

    before do
      when_current_user_is user
      visit edit_position_path(position)
    end

    it 'removes the email from the page when remove is clicked' do
      within('.subscriptions') { click_on 'Remove subscription' }
      find_button('Subscribe')
      expect(page).to have_no_text(subscription.email)
    end
  end
end
