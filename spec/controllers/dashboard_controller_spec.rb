require 'rails_helper'

describe DashboardController do
  describe 'GET #main' do
    context 'as staff' do
      before :each do
        @user = create :user, staff: true
        set_current_user_to @user
      end
      it 'redirects to staff dashboard' do
        get :main
        expect(response).to redirect_to staff_dashboard_path
      end
    end
    context 'as student' do
      before :each do
        @user = create :user, staff: false
        set_current_user_to @user
      end
      it 'redirects to student dashboard' do
        get :main
        expect(response).to redirect_to student_dashboard_path
      end
    end
  end
end
