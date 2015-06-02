require 'rails_helper'

describe DashboardController do
  describe 'GET #main' do
    context 'as staff' do
      it 'redirects to staff dashboard' do
        set_current_user_to :staff
        get :main
        expect(response).to redirect_to staff_dashboard_path
      end
    end
    context 'as student' do
      it 'redirects to student dashboard' do
        set_current_user_to :student
        get :main
        expect(response).to redirect_to student_dashboard_path
      end
    end
  end

  describe 'GET #staff' do
    let :submit do
      get :staff
    end
    context 'student' do
      it 'does not allow access' do
        set_current_user_to :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        set_current_user_to :staff
      end
      it 'assigns the required instance variables' do
        submit
        expect(assigns.keys).to include *%w(departments
                                            pending_interviews
                                            pending_records
                                            positions
                                            site_texts
                                            staff)
      end
    end
  end

  describe 'GET #student' do
    let :submit do
      get :student
    end
    context 'student' do
      before :each do
        set_current_user_to :student
      end
      it 'allows access' do
        submit
        expect(response).not_to have_http_status :unauthorized
      end
      it 'assigns the required instance variables' do
        submit
        expect(assigns.keys).to include *%w(application_records
                                            interviews
                                            positions)
      end
    end
  end
end
