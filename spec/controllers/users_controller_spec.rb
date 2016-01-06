require 'rails_helper'

describe UsersController do
  describe 'POST #create' do
    before :each do
      @user = attributes_for :user
    end
    let :submit do
      post :create, user: @user
    end
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      context 'invalid input' do
        before :each do
          @user = { first_name: '' }
        end
        it 'shows errors' do
          expect { submit }.to redirect_back
          expect(flash.keys).to include 'errors'
        end
      end
      context 'valid input' do
        it 'saves the user' do
          expect { submit }
            .to change { User.count }
            .by 1
        end
        it 'displays the user_create message' do
          expect_flash_message :user_create
          submit
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
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'destroys the user' do
        expect { submit }
          .to change { User.count }
          .by(-1)
      end
      it 'displays the user_destroy message' do
        expect_flash_message :user_destroy
        submit
      end
      it 'redirects to staff dashboard' do
        submit
        expect(response).to redirect_to staff_dashboard_path
      end
    end
  end

  describe 'GET #edit' do
    before :each do
      @user = create :user
    end
    let :submit do
      get :edit, id: @user.id
    end
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'renders the template' do
        submit
        expect(response).to render_template 'edit'
      end
    end
  end

  describe 'GET #new' do
    let :submit do
      get :new
    end
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'renders the template' do
        submit
        expect(response).to render_template 'new'
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @user = create :user
      @changes = { first_name: 'Glenn' }
    end
    let :submit do
      put :update, id: @user.id, user: @changes
    end
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'updates the user' do
        submit
        expect(@user.reload.first_name).to eql 'Glenn'
      end
      it 'displays the user_update message' do
        expect_flash_message :user_update
        submit
      end
      it 'redirects to staff dashboard' do
        submit
        expect(response).to redirect_to staff_dashboard_path
      end
      context 'invalid input' do
        before :each do
          @changes = { first_name: '' }
        end
        it 'flashes an error message' do
          expect { submit }.to redirect_back
          expect(flash.keys).to include 'errors'
        end
      end
    end
  end
end
