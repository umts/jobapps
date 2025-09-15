# frozen_string_literal: true

require 'rails_helper'

describe DashboardController do
  it_behaves_like 'an access-controlled resource', routes: [
    %i[get staff collection]
  ]
  describe 'GET #main' do
    it 'redirects to staff dashboard for staff users' do
      when_current_user_is :staff
      get :main
      expect(response).to redirect_to staff_dashboard_path
    end

    it 'redirects to student dashboard for student users' do
      when_current_user_is :student
      get :main
      expect(response).to redirect_to student_dashboard_path
    end

    it 'redirects to student dashboard with no user' do
      when_current_user_is nil
      get :main
      expect(response).to redirect_to student_dashboard_path
    end
  end

  describe 'GET #staff' do
    let(:submit) { get :staff }

    context 'when the current user is a student' do
      before { when_current_user_is :student }

      context 'with an XHR request' do
        let(:submit) { get :staff, xhr: true }

        it 'does not allow access' do
          submit
          expect(response).to have_http_status :unauthorized
        end
      end
    end

    context 'when the currrent user is staff' do
      before { when_current_user_is :staff }

      it 'assigns the required instance variables' do
        submit
        expect(assigns.keys).to include('departments', 'pending_interviews',
                                        'pending_records', 'positions',
                                        'staff')
      end
    end

    context 'when a staff memeber is logging in' do
      # Step 1: Unauthenticated user requests dashboard/staff.
      # Step 2: Unauthenticated user is redirected to Shibboleth login page.
      # Step 3: User authenticates as staff.
      # Step 4: User is redirected back to dashboard/staff,
      #         with the fcIdNumber in the request data from Shibboleth.
      # Step 5: This fcIdNumber is stored in the session as SPIRE,
      #         which sets the current user, and they are allowed access.
      #
      # This test assesses step 5.
      let(:user) { create(:user, :staff) }

      before do
        request.env['fcIdNumber'] = user.spire
      end

      it 'renders the correct page' do
        submit
        expect(response).to render_template 'staff'
      end

      it 'sets the correct current user' do
        submit
        expect(session[:user_id]).to eq(user.id)
      end
    end
  end

  describe 'GET #student' do
    let(:submit) { get :student }

    context 'with no user' do
      before { when_current_user_is nil }

      it 'allows access' do
        submit
        expect(response).not_to have_http_status :unauthorized
      end

      it 'assigns the required instance variables' do
        submit
        expect(assigns.keys).to include 'positions'
      end
    end

    context 'when the current user is a student' do
      before { when_current_user_is :student }

      it 'allows access' do
        submit
        expect(response).not_to have_http_status :unauthorized
      end

      it 'assigns the required instance variables' do
        submit
        expect(assigns.keys).to include('application_submissions', 'interviews', 'positions')
      end
    end
  end

  describe 'primary account check' do
    let(:submit) { get :main }

    context 'when loging in with a subsidiary account' do
      before do
        when_current_user_is :student
        admin = create(:user, :admin)
        request.env.merge! 'uid' => session[:user_id], 'UMAPrimaryAccount' => admin.id
      end

      it 'prohibits access' do
        submit
        expect(response).to have_http_status :unauthorized
      end

      it 'renders unauthenticated subsidiary haml' do
        submit
        expect(response).to render_template 'sessions/unauthenticated_subsidiary'
      end
    end

    context 'when loging in with a primary account' do
      before do
        when_current_user_is :student
        request.env.merge! 'uid' => session[:user_id], 'UMAPrimaryAccount' => session[:user_id]
      end

      it 'goes to dashboard' do
        submit
        expect(response).to redirect_to student_dashboard_path
      end
    end
  end
end
