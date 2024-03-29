# frozen_string_literal: true

require 'rails_helper'

describe ApplicationTemplatesController do
  it_behaves_like 'an access-controlled resource', routes: [
    %i[get new collection],
    %i[post toggle_active member],
    %i[post toggle_eeo_enabled member]
  ]
  describe 'GET #new' do
    context 'staff' do
      before do
        @user = create(:user, staff: true)
        when_current_user_is @user
        @position = create(:position)
      end

      let :submit do
        get :new, params: { position_id: @position.id }
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
        draft = create(:application_draft)
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
    before do
      department = create(:department, name: 'Bus')
      position = create(:position, name: 'Operator', department:)
      @template = create(:application_template, position:)
      @record = create(:application_submission,
                       data: [['a question', 'an answer', 'data type', 1]])
    end

    context 'using specific route' do
      let :submit do
        get :show, params: { id: @template.slug }
      end

      let :submit_with_load_id do
        get :show, params: { id: @template.slug, load_id: @record.id }
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
    before do
      department = create(:department, name: 'Bus')
      position = create(:position, department:, name: 'Operator')
      @template = create(:application_template, position:)
    end

    let :submit do
      post :toggle_active, params: {
        id: @template.id,
        position: @template.position.name,
        department: @template.department.name
      }
    end

    context 'staff' do
      before do
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
        expect(response).to redirect_to 'http://test.host/redirect'
      end
    end
  end

  describe 'POST #toggle_eeo_enabled' do
    before do
      department = create(:department, name: 'Bus')
      position = create(:position, department:, name: 'Operator')
      @template = create(:application_template, position:)
    end

    let :submit do
      post :toggle_eeo_enabled, params: {
        id: @template.id,
        position: @template.position.name,
        department: @template.department.name
      }
    end

    context 'staff' do
      before do
        @user = create(:user, staff: true)
        when_current_user_is @user
        request.env['HTTP_REFERER'] = 'http://test.host/redirect'
      end

      it 'changes eeo_enabled when called' do
        expect { submit }.to change { @template.reload.eeo_enabled }
      end

      context 'eeo is disabled' do
        before do
          # First, disable EEO
          @template.update eeo_enabled: false
        end

        it 'enables eeo' do
          submit
          expect(@template.reload.eeo_enabled).to be true
        end
      end

      context 'eeo is enabled' do
        before do
          # First, enable EEO
          @template.update eeo_enabled: true
        end

        it 'disbles EEO' do
          submit
          expect(@template.reload.eeo_enabled).to be false
        end
      end

      context 'redirecting with no HTTP_REFERER' do
        before do
          request.env['HTTP_REFERER'] = nil
        end

        context 'draft belonging to current user' do
          it 'redirects to the edit path' do
            @template.create_draft @user
            submit
            expect(response).to redirect_to(
              edit_draft_path(@template.draft_belonging_to @user)
            )
          end
        end

        context 'no draft belonging to current user' do
          it 'redirects to the application path' do
            submit
            expect(response).to redirect_to application_path(@template)
          end
        end
      end

      it 'redirects back' do
        submit
        expect(response).to redirect_to 'http://test.host/redirect'
      end
    end
  end

  describe 'POST #toggle_unavailability_enabled' do
    before do
      department = create(:department)
      position = create(:position, department:)
      @template = create(:application_template, position:)
    end

    let :submit do
      post :toggle_unavailability_enabled, params: {
        id: @template.id,
        position: @template.position.name,
        department: @template.department.name
      }
    end

    context 'staff' do
      before do
        @user = create(:user, staff: true)
        when_current_user_is @user
        request.env['HTTP_REFERER'] = 'http://test.host/redirect'
      end

      it 'changes unavailability_enabled when called' do
        expect { submit }.to change { @template.reload.unavailability_enabled }
      end

      context 'unavailability is disabled' do
        before do
          @template.update unavailability_enabled: false
        end

        it 'enables unavailability' do
          submit
          expect(@template.reload.unavailability_enabled).to be true
        end
      end

      context 'unavailability is enabled' do
        before do
          @template.update unavailability_enabled: true
        end

        it 'disables unavailability' do
          submit
          expect(@template.reload.unavailability_enabled).to be false
        end
      end

      context 'redirecting with no HTTP_REFERER' do
        before do
          request.env['HTTP_REFERER'] = nil
        end

        context 'draft belonging to current user' do
          it 'redirects to the edit path' do
            @template.create_draft @user
            submit
            expect(response).to redirect_to(
              edit_draft_path(@template.draft_belonging_to @user)
            )
          end
        end

        context 'no draft belonging to current user' do
          it 'redirects to the application path' do
            submit
            expect(response).to redirect_to application_path(@template)
          end
        end
      end

      it 'redirects back' do
        submit
        expect(response).to redirect_to 'http://test.host/redirect'
      end
    end
  end

  describe 'POST #toggle_resume_upload_enabled' do
    before do
      department = create(:department)
      position = create(:position, department:)
      @template = create(:application_template, position:)
    end

    let :submit do
      post :toggle_resume_upload_enabled, params: {
        id: @template.id,
        position: @template.position.name,
        department: @template.department.name
      }
    end

    context 'staff' do
      before do
        @user = create(:user, staff: true)
        when_current_user_is @user
        request.env['HTTP_REFERER'] = 'http://test.host/redirect'
      end

      it 'changes resume_upload_enabled when called' do
        expect { submit }.to change { @template.reload.resume_upload_enabled }
      end

      context 'resume upload is disabled' do
        before do
          @template.update resume_upload_enabled: false
        end

        it 'enables resume upload' do
          submit
          expect(@template.reload.resume_upload_enabled).to be true
        end
      end

      context 'resume upload is enabled' do
        before do
          @template.update resume_upload_enabled: true
        end

        it 'disables resume upload' do
          submit
          expect(@template.reload.resume_upload_enabled).to be false
        end
      end

      context 'redirecting with no HTTP_REFERER' do
        before do
          request.env['HTTP_REFERER'] = nil
        end

        context 'draft belonging to current user' do
          it 'redirects to the edit path' do
            @template.create_draft @user
            submit
            expect(response).to redirect_to(
              edit_draft_path(@template.draft_belonging_to @user)
            )
          end
        end

        context 'no draft belonging to current user' do
          it 'redirects to the application path' do
            submit
            expect(response).to redirect_to application_path(@template)
          end
        end
      end

      it 'redirects back' do
        submit
        expect(response).to redirect_to 'http://test.host/redirect'
      end
    end
  end
end
