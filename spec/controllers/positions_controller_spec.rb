require'rails_helper'

describe PositionsController do
  describe 'POST #create' do
    before :each do
      @position = attributes_with_foreign_keys_for :position
    end
    let :submit do
      post :create, position: @position
    end
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @position = create :position
    end
    let :submit do
      delete :destroy, id: @position.id
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
      @position = create :position
    end
    let :submit do
      get :edit, id: @position.id
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
      @position = create :position
      @changes = { name: 'Operations Manager' }
    end
    let :submit do
      put :update, id: @position.id, position: @changes
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
