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
    it 'disallows student access' do
      set_current_user_to :student
      get :staff
      expect(response).to have_http_status :unauthorized
    end
  end

  describe 'GET #student' do
    it 'allows student access' do
      set_current_user_to :studennt
      get :student
      expect(response).not_to have_http_status :unauthorized
    end
  end
end
