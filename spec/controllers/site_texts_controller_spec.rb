require 'rails_helper'

describe SiteTextsController do
  it_behaves_like 'an access-controlled resource', routes: [
    [:get,  :edit, :member],
    [:put,  :update, :member],
    [:get,  :request_new, :collection],
    [:post, :request_new, :collection],
    [:get,  :show, :member]
  ]
  describe '#edit methods' do
    before :each do
      @site_text = create :site_text
    end
    context 'GET' do
      let :submit do
        get :edit, id: @site_text.id
      end
      context 'staff' do
        before :each do
          when_current_user_is :staff
        end
        it 'renders the correct template' do
          submit
          expect(response).to render_template 'edit'
        end
      end
    end

    context 'POST' do
      before :each do
        @input = 'input'
      end
      let :submit do
        get :edit, id: @site_text.id, preview_input: @input
      end
      context 'staff' do
        before :each do
          when_current_user_is :staff
        end
        it 'passes preview input parameter through as an instance variable' do
          submit
          expect(assigns[:preview_input]).to eql @input
        end
      end
    end
  end

  describe 'PUT #update' do
    before :each do
      @site_text = create :site_text
      @changes = { text: 'new text' }
    end
    let :submit do
      put :update, id: @site_text.id, site_text: @changes
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      context 'invalid input' do
        before :each do
          @changes = { text: '' }
        end
        it 'redirects back with errors' do
          expect { submit }.to redirect_back
          expect(flash.keys).to include 'errors'
        end
      end
      context 'valid input' do
        it 'updates the site text' do
          submit
          expect(@site_text.reload.text).to eql 'new text'
        end
        it 'displays the site_text_update message' do
          expect_flash_message :site_text_update
          submit
        end
        it 'redirects to staff dashboard' do
          submit
          expect(response).to redirect_to staff_dashboard_path
        end
      end
    end
  end

  describe 'GET #request_new' do
    let :submit do
      get :request_new
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'renders the correct template' do
        submit
        expect(response).to render_template 'request_new'
      end
    end
  end

  describe 'POST #request_new' do
    before :each do
      @location = 'requested location'
      @description = 'requested description'
    end
    let :submit do
      post :request_new, location: @location, description: @description
    end
    context 'staff' do
      before :each do
        @user = create :user, :staff
        when_current_user_is @user
      end
    end
  end

  describe 'GET #show' do
    context 'site text does not exist' do
      before :each do
        when_current_user_is :staff
      end
      let :submit do
        get :show, id: 'not a name of anything'
      end
      it 'raises RecordNotFound exception' do
        expect { submit }.to raise_error ActiveRecord::RecordNotFound
      end
    end
    context 'site text exists' do
      before :each do
        @site_text = create :site_text
      end
      let :submit do
        get :show, id: @site_text.id
      end
      context 'staff' do
        before :each do
          when_current_user_is :staff
        end
        it 'finds the right site text' do
          submit
          expect(assigns.fetch :site_text).to eql @site_text
        end
        it 'renders the show page' do
          submit
          expect(response).to render_template 'show'
        end
      end
    end
  end
end
