require 'rails_helper'

describe ApplicationTemplatesController do
  it_behaves_like 'an access-controlled resource', routes: [
    [:get, :new,                 :collection],
    [:post, :toggle_active,      :member],
    [:post, :toggle_eeo_enabled, :member]
  ]
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
      @record = create :filed_application,
                       data: [['a question', 'an answer', 'data type', 1]]
    end
    context 'using specific route' do
      let :submit do
        get :show, id: @template.slug
      end

      let :submit_with_load_id do
        get :show, id: @template.slug, load_id: @record.id
      end

      context 'with a record to preload from' do
        it 'gets the correct question hash' do
          when_current_user_is :student
          submit_with_load_id
          expect(assigns(:old_data)).to eq(@record.questions_hash)
        end
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
    context 'staff' do
      before :each do
        when_current_user_is :staff
        request.env['HTTP_REFERER'] = 'http://test.host/redirect'
      end
      it 'changes eeo_enabled when called' do
        expect { submit }.to change { @template.reload.eeo_enabled }
      end

      context 'eeo is disabled' do
        before :each do
          # First, disable EEO
          @template.update eeo_enabled: false
        end
        it 'enables eeo' do
          submit
          expect(@template.reload.eeo_enabled).to be true
        end
      end

      context 'eeo is enabled' do
        before :each do
          # First, enable EEO
          @template.update eeo_enabled: true
        end
        it 'disbles EEO' do
          submit
          expect(@template.reload.eeo_enabled).to be false
        end
      end

      it 'redirects back' do
        submit
        expect(response).to redirect_to :back
      end
    end
  end

  describe 'POST #toggle_unavailability_enabled' do
    before :each do
      department = create :department
      position = create :position, department: department
      @template = create :application_template, position: position
    end
    let :submit do
      post :toggle_unavailability_enabled,
           id: @template.id,
           position: @template.position.name,
           department: @template.department.name
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
        request.env['HTTP_REFERER'] = 'http://test.host/redirect'
      end
      it 'changes unavailability_enabled when called' do
        expect { submit }.to change { @template.reload.unavailability_enabled }
      end

      context 'unavailability is disabled' do
        before :each do
          @template.update unavailability_enabled: false
        end
        it 'enables unavailability' do
          submit
          expect(@template.reload.unavailability_enabled).to be true
        end
      end

      context 'unavailability is enabled' do
        before :each do
          @template.update unavailability_enabled: true
        end
        it 'disables unavailability' do
          submit
          expect(@template.reload.unavailability_enabled).to be false
        end
      end

      it 'redirects back' do
        expect { submit }.to redirect_back
      end
    end
  end
end
