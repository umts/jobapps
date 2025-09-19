# frozen_string_literal: true

require 'rails_helper'

describe SessionsController do
  describe 'DELETE #destroy' do
    before do
      when_current_user_is :anyone
      allow(session).to receive(:clear).and_call_original
    end

    let :submit do
      delete :destroy
    end

    context 'when in the development environment' do
      before do
        allow(Rails.env).to receive(:production?).and_return false
      end

      it 'redirects to dev_login' do
        expect(submit).to redirect_to dev_login_path
      end

      it 'clears the session' do
        submit
        expect(session).to have_received(:clear)
      end
    end

    context 'when in the production environment' do
      before do
        allow(Rails.env).to receive(:production?).and_return true
      end

      it 'redirects to something about Shibboleth' do
        expect(submit).to redirect_to %r{/Shibboleth.sso/Logout}
      end

      it 'clears the session' do
        submit
        expect(session).to have_received(:clear)
      end
    end
  end

  describe 'GET #dev_login' do
    let(:submit) { get :dev_login }

    before do
      when_current_user_is nil
      create(:user) # for SPIRE purposes
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
    let :submit do
      post :dev_login, params: { user_id: user.id }
    end

    let(:user) { create(:user) }

    before do
      when_current_user_is nil
    end

    it 'creates a session for the user specified' do
      submit
      expect(session[:user_id]).to eq(user.id)
    end

    context 'with a submitted SPIRE id' do
      it 'creates a session with that SPIRE' do
        post :dev_login, params: { spire: '12345678' }
        expect(session[:spire]).to eq('12345678')
      end
    end

    it 'redirects to main dashboard' do
      expect(submit).to redirect_to main_dashboard_path
    end
  end

  describe 'GET #unauthenticated' do
    let(:submit) { get :unauthenticated }

    it 'renders the correct template' do
      expect(submit).to render_template :unauthenticated
    end
  end
end
