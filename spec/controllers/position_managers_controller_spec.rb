# frozen_string_literal: true

require 'rails_helper'

describe PositionManagersController do
  let :appoint do
    post :create, params: { position_id: position.id, position_manager: { user_id: new_manager.id } }
  end
  let(:new_manager) { create(:user) }
  let(:position) { create(:position) }

  it_behaves_like 'an access-controlled resource', record: -> { create(:position_manager).id }, routes: [
    %i[delete destroy member]
  ]

  context 'when the current user manages the position' do
    before { when_current_user_is create(:user, :manager, managing: position) }

    it 'allows appointing another manager' do
      appoint
      expect(position.managers).to include(new_manager)
    end

    it 'allows removing a manager' do
      position_manager = create(:position_manager, position:)
      expect { delete :destroy, params: { id: position_manager.id } }.to change(PositionManager, :count).by(-1)
    end
  end

  context 'when the current user manages a different position' do
    before { when_current_user_is :manager }

    it 'does not allow appointing a manager' do
      expect { appoint }.to raise_error(ActionPolicy::Unauthorized)
    end
  end
end
