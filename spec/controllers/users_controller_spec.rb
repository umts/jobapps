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
        post :create, user: attrs
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
        delete :destroy, id: user
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
        attrs = FactoryGirl.build :user
        patch :update, id: user, user: attrs
        user.reload
        expect(user.first_name).to eql 'Dave'
        expect(user.email).to eql 'dave@example.com'
      end
    end
  end
end
