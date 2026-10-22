# frozen_string_literal: true

require 'rails_helper'

# Request specs don't include session data,
# equivalent to not being authenticated.
describe 'Authentication' do
  context 'with an unauthenticated user' do
    it 'responds with unauthorized so the login page can render in place' do
      get '/dashboard/staff'
      expect(response).to have_http_status :unauthorized
    end

    context 'when in development' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
        get '/dashboard/staff'
      end

      it 'renders the development login page in place' do
        expect(response.body).to include('Log in with Microsoft', 'Development login')
      end
    end

    context 'when in production' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
        get '/dashboard/staff'
      end

      it 'renders a login form that targets the OAuth endpoint' do
        expect(response.body).to include('/auth/entra_id')
      end

      it 'auto-submits the login form' do
        expect(response.body).to include('getElementById("production-login-form").submit()')
      end

      it 'does not offer the development login' do
        expect(response.body).not_to include('Development login')
      end
    end

    context 'with a non-HTML request' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
        get '/dashboard/staff', headers: { 'Accept' => 'application/json' }
      end

      it 'responds without a body' do
        expect(response.body).to be_blank
      end
    end

    # The maintenance_tasks engine controller carries its own layout; the login
    # page must still render in the application layout wherever the rescue fires.
    context 'when reaching a controller with its own layout' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
        get '/maintenance_tasks'
      end

      it 'renders the login page in the application layout' do
        expect(response.body).to include('umass-banner')
      end
    end
  end
end
