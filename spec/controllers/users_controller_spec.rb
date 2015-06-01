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
      context 'errors' do
        before :each do
          #What does this line accomplish?
          #What is this technique known as?
          expect(User).to receive(:create).and_return false
        end
        it 'shows errors' do
          #Can't quite look for the flash here, since we're stubbing
          #out the creation, which means the errors hash isn't created
          expect_any_instance_of(ApplicationController).
            to receive(:show_errors)
          submit
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before :each do
    end
    let :submit do
    end
    context 'student' do
    end
    context 'staff' do
    end
  end

  #describe #edit
  #describe #new
  #describe #update
end
