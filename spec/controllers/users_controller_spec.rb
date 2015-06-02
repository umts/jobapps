require 'rails_helper'

describe UsersController do
  describe 'POST #create' do
    before :each do
      #Why is this an instance variable?
      @user = attributes_for :user
    end
    #What does a let block do?
    let :submit do
      post :create, user: @user
    end
    context 'student' do
      #What does this test do?
      it 'does not allow access' do
        #Where does the set_current_user_to method come from?
        set_current_user_to :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        set_current_user_to :staff
      end
      context 'invalid input' do
        before :each do
          #What does this line accomplish?
          @user = {first_name: ''}
        end
        it 'shows errors' do
          expect_redirect_to_back{submit}
          expect(flash.keys).to include 'errors'
        end
      end
      context 'valid input' do
        it 'saves the user' do
          expect{submit}.to change{User.count}.by 1
        end
        it 'displays a flash message' do
          submit
          expect(flash.keys).to include 'message'
        end
        it 'redirects to staff dashboard' do
          submit
          expect(response).to redirect_to staff_dashboard_path
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
      @user = create :user 
    end
    let :submit do
      delete :destroy, id: @user.id
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
     it 'destroys the user' do
       expect{submit}.to change{User.count}.by -1
     end
     it 'flashes a confirmation message' do
       submit
       expect(flash.keys).to include 'message'
     end
     it 'redirects to staff dashboard' do
       submit
       expect(response).to redirect_to staff_dashboard_path
     end
    end
  end

  describe 'PUT #update' do
    before :each do
      @user = create :user
      @changes = {first_name: 'Glenn'}
    end
    let :submit do
      put :update, {id: @user.id, user: @changes}
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
      it 'updates the user' do
        submit
        expect(@user.reload.first_name).to eql 'Glenn'
      end
      it 'flashes a confirmation message' do
        submit
        expect(flash.keys).to include 'message'
      end
      it 'redirects to staff dashboard' do
        submit
        expect(response).to redirect_to staff_dashboard_path
      end
      context 'invalid input' do
        before :each do
          @changes = {first_name: ''}
        end
        it 'flashes an error message' do
          expect_redirect_to_back{submit}
          expect(flash.keys).to include 'errors'
        end
      end
    end
  end
end
