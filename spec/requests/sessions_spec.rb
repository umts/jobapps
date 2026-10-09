# frozen_string_literal: true

require 'rails_helper'

describe 'Sessions' do
  describe 'POST /logout' do
    subject(:submit) { post '/logout' }

    before do
      when_current_user_is :anyone

      allow(Rails.application).to receive(:credentials)
        .and_return(entra_id: { tenant_id: 'tenant' })

      Rails.application.env_config['omniauth.auth'] = OmniAuth::AuthHash.new(
        provider: 'entra_id',
        uid: 'entra-uid-abc',
        info: {}
      )

      get '/auth/entra_id/callback'
    end

    after do
      Rails.application.env_config.delete('omniauth.auth')
    end

    it 'clears the session' do
      submit
      expect(session[:entra_uid]).to be_nil
    end

    context 'when not in development' do
      it 'redirects to the Entra logout URL' do
        submit
        expect(response).to redirect_to(
          "https://login.microsoftonline.com/tenant/oauth2/v2.0/logout?post_logout_redirect_uri=#{CGI.escape(root_url)}"
        )
      end
    end

    context 'when in development' do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
      end

      it 'redirects to the root path' do
        submit
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET /auth/entra_id/callback' do
    subject(:call) { get '/auth/entra_id/callback' }

    let(:auth_uid) { 'entra-uid-abc' }
    let(:auth_info) do
      {
        email: 'jane@umass.edu',
        first_name: 'Jane',
        last_name: 'Doe'
      }
    end
    let(:auth_extra) { { raw_info: { 'upn' => 'jdoe@umass.edu' } } }

    before do
      Rails.application.env_config['omniauth.auth'] = OmniAuth::AuthHash.new(
        provider: 'entra_id',
        uid: auth_uid,
        info: auth_info,
        extra: auth_extra
      )
    end

    after do
      Rails.application.env_config.delete('omniauth.auth')
      Rails.application.env_config.delete('omniauth.origin')
    end

    it 'stores the authenticated identity in the session' do
      call
      expect(session[:entra_uid]).to eq(auth_uid)
    end

    it 'redirects to the main dashboard' do
      call
      expect(response).to redirect_to(root_path)
    end

    context 'when no user matches the entra_uid' do
      it 'creates the user' do
        expect { call }.to change(User, :count).by(1)
      end

      it 'populates the new user from Active Directory' do
        call
        expect(User.find_by(entra_uid: auth_uid)).to have_attributes(
          first_name: 'Jane', last_name: 'Doe', email: 'jane@umass.edu', entra_upn: 'jdoe@umass.edu'
        )
      end

      context 'when Active Directory omits the UPN' do
        let(:auth_extra) { nil }

        it 'creates the user without a UPN' do
          call
          expect(User.find_by(entra_uid: auth_uid).entra_upn).to be_nil
        end
      end
    end

    context 'when a user with the entra_uid exists' do
      let!(:user) do
        create(
          :user,
          entra_uid: auth_uid,
          first_name: 'Old',
          last_name: 'Name',
          email: 'old@example.com'
        )
      end

      it 'does not create another user' do
        expect { call }.not_to change(User, :count)
      end

      it 'syncs their name and UPN from Active Directory' do
        call
        expect(user.reload).to have_attributes(
          first_name: 'Jane', last_name: 'Doe', entra_upn: 'jdoe@umass.edu'
        )
      end

      it 'leaves their email untouched so a preferred address is kept' do
        expect { call }.not_to change { user.reload.email }.from('old@example.com')
      end

      context 'when only a uid is sent, as with the developer login' do
        let(:auth_info) { {} }
        let(:auth_extra) { nil }

        it 'logs them in' do
          call
          expect(session[:entra_uid]).to eq(auth_uid)
        end

        it 'keeps their existing name rather than blanking it' do
          call
          expect(user.reload).to have_attributes(
            first_name: 'Old',
            last_name: 'Name'
          )
        end
      end

      context 'when Active Directory returns blank names' do
        let(:auth_info) do
          {
            email: 'jane@umass.edu',
            first_name: '',
            last_name: ' '
          }
        end

        it 'keeps their existing names' do
          call
          expect(user.reload).to have_attributes(
            first_name: 'Old',
            last_name: 'Name'
          )
        end
      end

      context 'when Active Directory omits the UPN on a later login' do
        let(:auth_extra) { { raw_info: {} } }

        before do
          user.update!(entra_upn: 'jdoe@umass.edu')
        end

        it 'keeps the UPN already on record' do
          expect { call }.not_to change { user.reload.entra_upn }
            .from('jdoe@umass.edu')
        end
      end
    end

    context 'when an origin was recorded' do
      before do
        Rails.application.env_config['omniauth.origin'] = student_dashboard_path
      end

      it 'redirects back to the origin' do
        call
        expect(response).to redirect_to(student_dashboard_path)
      end
    end
  end
end
