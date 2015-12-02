require 'rails_helper'

describe DashboardController do
  describe 'GET #main' do
    context 'as staff' do
      it 'redirects to staff dashboard' do
        when_current_user_is :staff
        get :main
        expect(response).to redirect_to staff_dashboard_path
      end
    end
    context 'as student' do
      it 'redirects to student dashboard' do
        when_current_user_is :student
        get :main
        expect(response).to redirect_to student_dashboard_path
      end
    end
    context 'as no user' do
      it 'redirects to student dashboard' do
        when_current_user_is nil
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
      before :each do
        when_current_user_is :student
      end
      context 'HTML request' do
        it 'does not allow access' do
          submit
          expect(response).to have_http_status :unauthorized
        end
      end
      context 'XHR request' do
        it 'does not allow access' do
          xhr :get, :staff
          expect(response).to have_http_status :unauthorized
          expect(response.body).to be_blank
        end
      end
    end
    context 'staff' do
      context 'already logged in' do
        before :each do
          when_current_user_is :staff
        end
        it 'assigns the required instance variables' do
          submit
          expect(assigns.keys).to include(*%w(departments
                                              pending_interviews
                                              pending_records
                                              positions
                                              site_texts
                                              staff))
        end
      end
      context 'in the process of logging in' do
        # Step 1: Unauthenticated user requests dashboard/staff.
        # Step 2: Unauthenticated user is redirected to Shibboleth login page.
        # Step 3: User authenticates as staff.
        # Step 4: User is redirected back to dashboard/staff,
        #         with the fcIdNumber in the request data from Shibboleth.
        # Step 5: This fcIdNumber is stored in the session as SPIRE,
        #         which sets the current user, and they are allowed access.
        #
        # This test assesses step 5.
        before :each do
          @user = create :user, :staff
          request.env['fcIdNumber'] = @user.spire
        end
        it 'renders the correct page' do
          submit
          expect(response).not_to have_http_status :unauthorized
          expect(response).to render_template 'staff'
        end
        it 'sets the correct current user' do
          submit
          expect(assigns.fetch :current_user).to eql @user
        end
      end
    end
  end

  describe 'GET #student' do
    let :submit do
      get :student
    end
    context 'no user' do
      before :each do
        when_current_user_is nil
      end
      it 'allows access' do
        submit
        expect(response).not_to have_http_status :unauthorized
      end
      it 'assigns the required instance variables' do
        submit
        expect(assigns.keys).to include 'positions'
      end
    end
    context 'student' do
      before :each do
        when_current_user_is :student
      end
      it 'allows access' do
        submit
        expect(response).not_to have_http_status :unauthorized
      end
      it 'assigns the required instance variables' do
        submit
        expect(assigns.keys).to include(*%w(application_records
                                            interviews
                                            positions))
      end
    end
  end
end
