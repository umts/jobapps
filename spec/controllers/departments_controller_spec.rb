require 'rails_helper'

describe DepartmentsController do
  describe 'POST #create' do
    before :each do
      @department = attributes_for :department
    end
    let :submit do
      post :create, department: @department
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
      @department = create :department
    end
    let :submit do
      delete :destroy, id: @department.id
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
      @department = create :department
    end
    let :submit do
      get :edit, id: @department.id
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
      @department = create :department
      @changes = { name: 'Operations' }
    end
    let :submit do
      put :update, id: @department.id, department: @changes
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
