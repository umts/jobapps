require 'rails_helper'

describe UsersController do
  it_behaves_like 'an access-controlled resource', routes: [
    [:post,   :create],
    [:delete, :destroy, id: 0],
    [:get,    :edit,    id: 0],
    [:get,    :new],
    [:put,    :update,  id: 0]
  ]

  describe 'POST #create' do
    before :each do
      @user = attributes_for :user
    end
    let :submit do
      post :create, user: @user
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @user = create :user
    end
    let :submit do
      delete :destroy, id: @user.id
    end
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'GET #edit' do
    before :each do
      @user = create :user
    end
    let :submit do
      get :edit, id: @user.id
    end
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'GET #new' do
    let :submit do
      get :new
    end
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @user = create :user
      @changes = { first_name: 'Glenn' }
    end
    let :submit do
      put :update, id: @user.id, user: @changes
    end
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end
end
