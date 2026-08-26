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
          expect { submit }.to raise_error(Unauthorized)
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
end
