# frozen_string_literal: true

require 'rails_helper'

describe SubscriptionsController do
  it_behaves_like 'an access-controlled resource', record: -> { create(:subscription).id }, routes: [
    %i[delete destroy member]
  ]

  it 'does not allow subscribing to a position the current user does not manage' do
    user = create(:user, :manager)
    when_current_user_is user
    params = { subscription: { email: 'me@umass.edu', position_id: create(:position).id, user_id: user.id } }
    expect { post :create, params: }.to raise_error(ActionPolicy::Unauthorized)
  end

  context 'when the current user manages the position' do
    let(:position) { create(:position) }
    let(:user) { create(:user, :manager, managing: position) }

    before { when_current_user_is user }

    it 'allows subscribing to it' do
      params = { subscription: { email: 'me@umass.edu', position_id: position.id, user_id: user.id } }
      expect { post :create, params: }.to change(Subscription, :count).by(1)
    end

    it 'allows removing its subscriptions' do
      subscription = create(:subscription, position:)
      expect { delete :destroy, params: { id: subscription.id } }.to change(Subscription, :count).by(-1)
    end
  end
end
