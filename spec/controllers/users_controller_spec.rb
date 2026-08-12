# frozen_string_literal: true

require 'rails_helper'

describe UsersController do
  it_behaves_like 'an access-controlled resource', routes: [
    %i[post create collection],
    %i[delete destroy member],
    %i[get edit member],
    %i[get new collection],
    %i[put update member]
  ]
  describe 'POST #create' do
    context 'when the current user is staff' do
      before do
        when_current_user_is :staff
      end

      it 'does not create the user' do
        post :create, params: { user: build(:user) }
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when the current user is staff' do
      let(:user) { create(:user, :staff) }

      before do
        when_current_user_is :staff
      end

      it 'does not allow the request' do
        delete :destroy, params: { id: user }
        expect(response).to have_http_status :unauthorized
      end

      it 'does not destroy the user' do
        delete :destroy, params: { id: user }
        expect(User.all).to include user
      end
    end
  end

  describe 'PUT #update' do
    context 'when the current user is staff' do
      let(:user) { create(:user) }

      before do
        when_current_user_is :staff
      end

      it 'does not update the user' do
        expect do
          put :update, params: { id: user, user: build(:user) }
        end.not_to(change { user.reload.attributes })
      end
    end
  end

  describe 'PUT #promote_save' do
    context 'when the current user is staff' do
      let(:user) { create(:user) }

      before do
        when_current_user_is :staff
      end

      it 'does not promote the user' do
        put :promote_save, params: { user: "#{user.full_name} #{user.spire}" }
        user.reload
        expect(user).not_to be_staff
      end
    end
  end
end
