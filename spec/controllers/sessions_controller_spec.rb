# frozen_string_literal: true

require 'rails_helper'

describe SessionsController do
  describe 'GET #create' do
    let :auth_hash do
      OmniAuth::AuthHash.new(
        uid: 'entra-uid-abc',
        info: { email: 'jane@umass.edu', first_name: 'Jane', last_name: 'Doe' },
        extra: { raw_info: { upn: 'jdoe@umass.edu' } }
      )
    end

    before do
      request.env['omniauth.auth'] = auth_hash
    end

    it 'stores the authenticated identity in the session' do
      get :create, params: { provider: 'entra_id' }
      expect(session[:entra_uid]).to eq 'entra-uid-abc'
    end

    it 'creates the user on first login' do
      expect { get :create, params: { provider: 'entra_id' } }.to change(User, :count).by(1)
    end

    it 'populates the new user from Active Directory' do
      get :create, params: { provider: 'entra_id' }
      expect(User.find_by(entra_uid: 'entra-uid-abc'))
        .to have_attributes(first_name: 'Jane', last_name: 'Doe', email: 'jane@umass.edu', entra_upn: 'jdoe@umass.edu')
    end

    it 'redirects to the main dashboard' do
      get :create, params: { provider: 'entra_id' }
      expect(response).to redirect_to root_path
    end

    context 'when the user already exists' do
      before do
        create(:user, entra_uid: 'entra-uid-abc',
                      first_name: 'Old', last_name: 'Name', email: 'old@example.com')
      end

      it 'does not create another user' do
        expect { get :create, params: { provider: 'entra_id' } }.not_to change(User, :count)
      end

      it 'syncs their name and UPN from Active Directory' do
        get :create, params: { provider: 'entra_id' }
        expect(User.find_by(entra_uid: 'entra-uid-abc'))
          .to have_attributes(first_name: 'Jane', last_name: 'Doe', entra_upn: 'jdoe@umass.edu')
      end

      it 'leaves their email untouched so a preferred address is kept' do
        get :create, params: { provider: 'entra_id' }
        expect(User.find_by(entra_uid: 'entra-uid-abc').email).to eq 'old@example.com'
      end

      context 'when only a uid is sent, as with the developer login' do
        let(:auth_hash) { OmniAuth::AuthHash.new(uid: 'entra-uid-abc', info: {}) }

        it 'logs them in' do
          get :create, params: { provider: 'developer' }
          expect(session[:entra_uid]).to eq 'entra-uid-abc'
        end

        it 'keeps their existing name rather than blanking it' do
          get :create, params: { provider: 'developer' }
          expect(User.find_by(entra_uid: 'entra-uid-abc'))
            .to have_attributes(first_name: 'Old', last_name: 'Name')
        end
      end

      context 'when Active Directory omits the UPN on a later login' do
        let :auth_hash do
          OmniAuth::AuthHash.new(
            uid: 'entra-uid-abc',
            info: { email: 'jane@umass.edu', first_name: 'Jane', last_name: 'Doe' },
            extra: { raw_info: {} }
          )
        end

        before { User.find_by(entra_uid: 'entra-uid-abc').update!(entra_upn: 'jdoe@umass.edu') }

        it 'keeps the UPN already on record' do
          get :create, params: { provider: 'entra_id' }
          expect(User.find_by(entra_uid: 'entra-uid-abc').entra_upn).to eq 'jdoe@umass.edu'
        end
      end
    end

    context 'when Active Directory omits the UPN' do
      let :auth_hash do
        OmniAuth::AuthHash.new(
          uid: 'entra-uid-abc',
          info: { email: 'jane@umass.edu', first_name: 'Jane', last_name: 'Doe' }
        )
      end

      it 'creates the user without a UPN' do
        get :create, params: { provider: 'entra_id' }
        expect(User.find_by(entra_uid: 'entra-uid-abc').entra_upn).to be_nil
      end
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
