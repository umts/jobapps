# frozen_string_literal: true

require 'rails_helper'

describe SessionsController do
  describe 'DELETE #destroy' do
    before do
      @user = create(:user)
      when_current_user_is @user
    end

    let :submit do
      delete :destroy
    end

    context 'development' do
      before do
        expect(Rails.env)
          .to receive(:production?)
          .and_return false
      end

      it 'redirects to dev_login' do
        submit
        expect(response).to redirect_to dev_login_path
      end

      it 'clears the session' do
        expect_any_instance_of(ActionController::TestSession)
          .to receive :clear
        submit
      end
    end

    context 'production' do
      before do
        expect(Rails.env)
          .to receive(:production?)
          .and_return true
      end

      it 'redirects to something about Shibboleth' do
        submit
        expect(response).to redirect_to '/Shibboleth.sso/Logout?return=https://webauth.umass.edu/Logout'
      end

      it 'clears the session' do
        expect_any_instance_of(ActionController::TestSession)
          .to receive :clear
        submit
      end
    end
  end

  describe 'GET #dev_login' do
    before do
      when_current_user_is nil
      create(:user) # for SPIRE purposes
    end

    let :submit do
      get :dev_login
    end

    it 'assigns instance variables' do
      submit
      expect(assigns.keys).to include 'staff', 'students'
    end

    it 'renders correct template' do
      submit
      expect(response).to render_template 'dev_login'
    end
  end

  describe 'POST #dev_login' do
    before do
      when_current_user_is nil
      @user = create(:user)
    end

    let :submit do
      post :dev_login, params: { user_id: @user.id }
    end

    it 'creates a session for the user specified' do
      submit
      expect(session[:user_id]).to eql @user.id
    end

    context 'SPIRE submitted' do
      it 'creates a session with that SPIRE' do
        post :dev_login, params: { spire: '12345678' }
        expect(session[:spire]).to eql '12345678'
      end
    end

    it 'redirects to main dashboard' do
      submit
      expect(response).to redirect_to main_dashboard_path
    end
  end

  describe 'GET #unauthenticated' do
    let :submit do
      get :unauthenticated
    end

    it 'renders the correct template' do
      expect(submit).to render_template :unauthenticated
    end
  end
end
