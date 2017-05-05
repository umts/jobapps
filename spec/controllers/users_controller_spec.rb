require 'rails_helper'

describe UsersController do
  it_behaves_like 'an access-controlled resource', routes: [
    [:post,   :create,  :collection],
    [:delete, :destroy, :member],
    [:get,    :edit,    :member],
    [:get,    :new,     :collection],
    [:put,    :update,  :member]
  ]
  describe 'POST #create' do
    context 'creating a user as staff' do
      it 'does not create the user' do
        when_current_user_is :staff
        attrs = FactoryGirl.build :user
        post :create, params: { user: attrs }
        expect(response).to have_http_status :unauthorized
        expect(response.body).not_to be_empty
      end
    end
  end
  describe 'DELETE #destroy' do
    context 'destroying a user as staff' do
      it 'does not destroy the user' do
        when_current_user_is :staff
        user = create :user, :staff
        delete :destroy, params: { id: user }
        expect(response).to have_http_status :unauthorized
        expect(User.all).to include user
      end
    end
  end
  describe 'PUT #update' do
    context 'updating a user as staff' do
      it 'does not update the user' do
        when_current_user_is :staff
        user = create :user
        initial_user = user
        attrs = FactoryGirl.build :user
        put :update, params: { id: user, user: attrs }
        user.reload
        expect(user).to eql initial_user
      end
    end
  end
  describe 'PUT #promote_save' do
    context 'promoting a user as staff' do
      it 'does not promote the user' do
        when_current_user_is :staff
        user = create :user
        put :promote_save, params:{ user: "#{user.full_name} #{user.spire}" }
        user.reload
        expect(user.staff).to be false
      end
    end
  end
end
