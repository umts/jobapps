# frozen_string_literal: true

require 'rails_helper'

describe PositionsController do
  it_behaves_like 'an access-controlled resource', record: -> { create(:position).id }, routes: [
    %i[post create collection],
    %i[delete destroy member],
    %i[get edit member],
    %i[get new collection],
    %i[put update member],
    %i[get saved_applications member]
  ]

  context 'when the current user manages the position' do
    let(:position) { create(:position) }

    before { when_current_user_is create(:user, :manager, managing: position) }

    it 'allows editing it' do
      put :update, params: { id: position.id, position: { name: 'New name' } }
      expect(position.reload.name).to eq('New name')
    end

    it 'allows viewing its saved applications' do
      get :saved_applications, params: { id: position.id }
      expect(assigns[:saved]).to be_empty
    end

    it 'does not allow creating positions' do
      expect { get :new }.to raise_error(ActionPolicy::Unauthorized)
    end

    it 'allows deleting it' do
      expect { delete :destroy, params: { id: position.id } }.to change(Position, :count).by(-1)
    end
  end

  context 'when the current user is an admin' do
    before { when_current_user_is :admin }

    it 'allows creating positions' do
      expect { post :create, params: { position: { name: 'Driver' } } }.to change(Position, :count).by(1)
    end
  end
end
