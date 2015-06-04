require 'rails_helper'

describe PositionsController do
  describe 'POST #create' do
    before :each do
      @position = attributes_with_foreign_keys_for :position
    end
    let :submit do
      post :create, position: @position
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
          @position = { name: '' }
        end
        it 'shows errors' do
          expect_redirect_to_back { submit }
          expect(flash.keys).to include 'errors'
        end
      end
      context 'valid input' do
        it 'saves the position' do
          expect { submit }
            .to change { Position.count }
            .by 1
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
      @position = create :position
    end
    let :submit do
      delete :destroy, id: @position.id
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
      it 'destroys the position' do
        expect { submit }
          .to change { Position.count }
          .by(-1)
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

  describe 'GET #edit' do
    before :each do
      @position = create :position
    end
    let :submit do
      get :edit, id: @position.id
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
      @position = create :position
      @changes = { name: 'Operations Manager' }
    end
    let :submit do
      put :update, id: @position.id, position: @changes
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
      it 'updates the position' do
        submit
        expect(@position.reload.name).to eql 'Operations Manager'
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
          @changes = { name: '' }
        end
        it 'flashes an error message' do
          expect_redirect_to_back { submit }
          expect(flash.keys).to include 'errors'
        end
      end
    end
  end
end
