require 'rails_helper'

describe ApplicationTemplatesController do
  describe 'GET #new' do
    context 'staff' do
      before :each do
        @user = create :user, staff: true
        when_current_user_is @user
        @position = create :position
      end
      let :submit do
        get :new, position_id: @position.id
      end
      it 'creates an application template for that position' do
        expect(@position.application_template).to be_nil
        submit
        expect(@position.reload.application_template).not_to be_nil
      end
      it 'creates a draft for that application template for the current user' do
        submit
        draft = assigns.fetch :draft
        expect(draft.user).to eql @user
      end
      it 'assigns the created draft to a draft variable' do
        draft = create :application_draft
        expect_any_instance_of(ApplicationTemplate)
          .to receive(:create_draft).with(@user).and_return draft
        submit
        expect(assigns.fetch :draft).to eql draft
      end
      it 'redirects to the edit page for that draft' do
        submit
        draft = assigns.fetch :draft
        expect(response).to redirect_to edit_draft_path(draft)
      end
    end
  end

  describe 'GET #show' do
    before :each do
      department = create :department, name: 'Bus'
      position = create :position, name: 'Operator', department: department
      @template = create :application_template, position: position
    end
    context 'using specific route' do
      let :submit do
        get :show, id: @template.slug
      end
      context 'no user' do
        it 'allows access' do
          when_current_user_is nil
          submit
          expect(response).not_to have_http_status :unauthorized
        end
      end
      context 'student' do
        it 'allows access' do
          when_current_user_is :student
          submit
          expect(response).not_to have_http_status :unauthorized
        end
      end
      context 'staff' do
        it 'allows access' do
          when_current_user_is :staff
          submit
          expect(response).not_to have_http_status :unauthorized
        end
      end
    end
  end

  describe 'POST #toggle_active' do
    before :each do
      department = create :department, name: 'Bus'
      position = create :position, department: department, name: 'Operator'
      @template = create :application_template, position: position
    end
    let :submit do
      post :toggle_active,
           id: @template.id,
           position: @template.position.name,
           department: @template.department.name
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
        request.env['HTTP_REFERER'] = 'http://test.host/redirect'
      end
      context 'button to activate application template has been pressed' do
        it 'marks the application as active' do
          @template.update active: false
          expect { submit }.to change { @template.reload.active? }
        end
      end
      context 'button to deactivate application template has been pressed' do
        it 'marks the application as inactive' do
          @template.update active: true
          expect { submit }.to change { @template.reload.active? }
        end
      end
      it 'redirects back' do
        submit
        expect(response).to redirect_to :back
      end
    end
  end
    describe 'POST #toggle_eeo_enabled' do
    before :each do
      department = create :department, name: 'Bus'
      position = create :position, department: department, name: 'Operator'
      @template = create :application_template, position: position
    end
    let :submit do
      post :toggle_eeo_enabled,
           id: @template.id,
           position: @template.position.name,
           department: @template.department.name
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
        request.env['HTTP_REFERER'] = 'http://test.host/redirect'
        #set the eeo_enabled attribute to false first
        @template.update eeo_enabled: false
      end
      it 'changes eeo_enabled when called' do 
        expect { submit }.to change { @template.reload.eeo_enabled }
      end
      context 'eeo is disabled' do
        before :each do
          
        end
      end
      it ''
        expect(@template.reload.eeo_enabled?).to eql false
        submit
        expect(@template.reload.eeo_enabled).to eql true
      end
      it 'redirects back' do
        submit
        expect(response).to redirect_to :back
      end
    end
  end
end
