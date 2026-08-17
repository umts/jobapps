# frozen_string_literal: true

require 'rails_helper'

describe SessionsController do
  describe 'GET #create' do
    let :auth_hash do
      OmniAuth::AuthHash.new(
        uid: 'entra-uid-abc',
        info: { email: 'jane@umass.edu', first_name: 'Jane', last_name: 'Doe' }
      )
    end

    before do
      request.env['omniauth.auth'] = auth_hash
    end

    it 'stores the authenticated identity in the session' do
      get :create, params: { provider: 'entra_id' }
      expect(session[:entra_uid]).to eq 'entra-uid-abc'
    end

    it 'redirects to the main dashboard' do
      get :create, params: { provider: 'entra_id' }
      expect(response).to redirect_to main_dashboard_path
    end

    context 'when an origin was recorded' do
      before do
        request.env['omniauth.origin'] = student_dashboard_path
      end

      it 'redirects back to the origin' do
        get :create, params: { provider: 'entra_id' }
        expect(response).to redirect_to student_dashboard_path
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      when_current_user_is :anyone
      allow(session).to receive(:clear).and_call_original
    end

    context 'when in the development environment' do
      it 'redirects to the root path, which renders the login page' do
        delete :destroy
        expect(response).to redirect_to root_path
      end

      it 'clears the session' do
        delete :destroy
        expect(session).to have_received(:clear)
      end
    end

    context 'when in the production environment' do
      before do
        allow(Rails.env).to receive(:production?).and_return true
        allow(Rails.application).to receive(:credentials)
          .and_return(entra_id: { tenant_id: 'tenant' })
      end

      it 'redirects to the Entra logout url' do
        delete :destroy
        expect(response).to redirect_to(
          "https://login.microsoftonline.com/tenant/oauth2/v2.0/logout?post_logout_redirect_uri=#{CGI.escape(root_url)}"
        )
      end

      it 'clears the session' do
        delete :destroy
        expect(session).to have_received(:clear)
      end
    end
  end
end
