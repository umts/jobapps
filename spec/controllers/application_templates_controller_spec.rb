# frozen_string_literal: true

require 'rails_helper'

describe ApplicationTemplatesController do
  it_behaves_like 'an access-controlled resource', routes: [
    %i[get new collection],
    %i[post toggle_active member],
    %i[post toggle_eeo_enabled member]
  ]

  describe 'GET #new' do
    context 'when the current user is staff' do
      let(:user) { create(:user, :staff) }
      let(:position) { create(:position) }
      let(:template) { create(:application_template, position:) }

      let :submit do
        get :new, params: { position_id: position.id }
      end

      before do
        when_current_user_is user
      end

      it 'creates an application template for that position' do
        expect { submit }.to change { position.reload.application_template }
          .from(nil).to be_a(ApplicationTemplate)
      end

      it 'creates a draft for that application template for the current user' do
        submit
        draft = assigns.fetch :draft
        expect(draft.user).to eq(user)
      end

      it 'assigns the created draft to a draft variable' do
        draft = create(:application_draft)
        allow(ApplicationTemplate).to receive(:create!).and_return(template)
        allow(template).to receive(:create_draft).and_return(draft)
        submit
        expect(assigns.fetch :draft).to eq(draft)
      end

      it 'redirects to the edit page for that draft' do
        submit
        draft = assigns.fetch :draft
        expect(response).to redirect_to edit_draft_path(draft)
      end
    end
  end

  describe 'GET #show' do
    let :template do
      department = create(:department, name: 'Bus')
      position = create(:position, name: 'Operator', department:)
      create(:application_template, position:)
    end
    let(:record) { create(:application_submission, data: [['a question', 'an answer', 'data type', 1]]) }

    context 'when using specific route' do
      let :submit do
        get :show, params: { id: template.slug }
      end

      let :submit_with_load_id do
        get :show, params: { id: template.slug, load_id: record.id }
      end

      context 'with a record to preload from' do
        it 'gets the correct question hash' do
          when_current_user_is :student
          submit_with_load_id
          expect(assigns(:old_data)).to eq(record.questions_hash)
        end
      end

      context 'with no user' do
        it 'allows access' do
          when_current_user_is nil
          submit
          expect(response).not_to have_http_status :unauthorized
        end
      end

      context 'when the current user is a student' do
        it 'allows access' do
          when_current_user_is :student
          submit
          expect(response).not_to have_http_status :unauthorized
        end
      end

      context 'when the current user is staff' do
        it 'allows access' do
          when_current_user_is :staff
          submit
          expect(response).not_to have_http_status :unauthorized
        end
      end
    end
  end

  describe 'POST #toggle_active' do
    let :template do
      department = create(:department, name: 'Bus')
      position = create(:position, name: 'Operator', department:)
      create(:application_template, position:)
    end

    let :submit do
      post :toggle_active, params: {
        id: template.id,
        position: template.position.name,
        department: template.department.name
      }
    end

    context 'when the current user is staff' do
      before do
        when_current_user_is :staff
        request.env['HTTP_REFERER'] = 'http://test.host/redirect'
      end

      context 'when the button to activate application template has been pressed' do
        it 'marks the application as active' do
          template.update active: false
          expect { submit }.to change { template.reload.active? }
        end
      end

      context 'when the button to deactivate application template has been pressed' do
        it 'marks the application as inactive' do
          template.update active: true
          expect { submit }.to change { template.reload.active? }
        end
      end

      it 'redirects back' do
        submit
        expect(response).to redirect_to 'http://test.host/redirect'
      end
    end
  end

  describe 'POST #toggle_eeo_enabled' do
    let :template do
      department = create(:department, name: 'Bus')
      position = create(:position, department:, name: 'Operator')
      create(:application_template, position:)
    end

    let :submit do
      post :toggle_eeo_enabled, params: {
        id: template.id,
        position: template.position.name,
        department: template.department.name
      }
    end

    context 'when the current user is staff' do
      let(:user) { create(:user, :staff) }

      before do
        when_current_user_is user
        request.env['HTTP_REFERER'] = 'http://test.host/redirect'
      end

      it 'changes eeo_enabled when called' do
        expect { submit }.to change { template.reload.eeo_enabled }
      end

      context 'with eeo disabled' do
        before do
          template.update eeo_enabled: false
        end

        it 'enables eeo' do
          submit
          expect(template.reload.eeo_enabled).to be true
        end
      end

      context 'with eeo enabled' do
        before do
          template.update eeo_enabled: true
        end

        it 'disbles EEO' do
          submit
          expect(template.reload.eeo_enabled).to be false
        end
      end

      it 'redirects back' do
        submit
        expect(response).to redirect_to 'http://test.host/redirect'
      end

      context 'when redirecting with no HTTP_REFERER' do
        before { request.env['HTTP_REFERER'] = nil }

        context 'with a draft belonging to the current user' do
          before { template.create_draft user }

          it 'redirects to the edit path' do
            submit
            expect(response).to redirect_to(edit_draft_path(template.draft_belonging_to user))
          end
        end

        context 'without a draft belonging to the current user' do
          it 'redirects to the application path' do
            submit
            expect(response).to redirect_to(application_path(template))
          end
        end
      end
    end
  end

  describe 'POST #toggle_unavailability_enabled' do
    let :template do
      department = create(:department)
      position = create(:position, department:)
      create(:application_template, position:)
    end

    let :submit do
      post :toggle_unavailability_enabled, params: {
        id: template.id,
        position: template.position.name,
        department: template.department.name
      }
    end

    context 'when the current user is staff' do
      let(:user) { create(:user, :staff) }

      before do
        when_current_user_is user
        request.env['HTTP_REFERER'] = 'http://test.host/redirect'
      end

      context 'with unavailability disabled' do
        before do
          template.update unavailability_enabled: false
        end

        it 'enables unavailability' do
          submit
          expect(template.reload.unavailability_enabled).to be(true)
        end
      end

      context 'with unavailability enabled' do
        before do
          template.update unavailability_enabled: true
        end

        it 'disables unavailability' do
          submit
          expect(template.reload.unavailability_enabled).to be(false)
        end
      end

      it 'redirects back' do
        submit
        expect(response).to redirect_to 'http://test.host/redirect'
      end

      context 'when redirecting with no HTTP_REFERER' do
        before { request.env['HTTP_REFERER'] = nil }

        context 'with a draft belonging to the current user' do
          before { template.create_draft user }

          it 'redirects to the edit path' do
            submit
            expect(response).to redirect_to(edit_draft_path(template.draft_belonging_to user))
          end
        end

        context 'without a draft belonging to current user' do
          it 'redirects to the application path' do
            submit
            expect(response).to redirect_to application_path(template)
          end
        end
      end
    end
  end

  describe 'POST #toggle_resume_upload_enabled' do
    let :template do
      department = create(:department)
      position = create(:position, department:)
      create(:application_template, position:)
    end

    let :submit do
      post :toggle_resume_upload_enabled, params: {
        id: template.id,
        position: template.position.name,
        department: template.department.name
      }
    end

    context 'when the current user is staff' do
      let(:user) { create(:user, :staff) }

      before do
        when_current_user_is user
        request.env['HTTP_REFERER'] = 'http://test.host/redirect'
      end

      context 'with resume upload disabled' do
        before do
          template.update resume_upload_enabled: false
        end

        it 'enables resume upload' do
          submit
          expect(template.reload.resume_upload_enabled).to be(true)
        end
      end

      context 'with resume upload enabled' do
        before do
          template.update resume_upload_enabled: true
        end

        it 'disables resume upload' do
          submit
          expect(template.reload.resume_upload_enabled).to be(false)
        end
      end

      it 'redirects back' do
        submit
        expect(response).to redirect_to 'http://test.host/redirect'
      end

      context 'when redirecting with no HTTP_REFERER' do
        before { request.env['HTTP_REFERER'] = nil }

        context 'with a draft belonging to the current user' do
          before { template.create_draft user }

          it 'redirects to the edit path' do
            submit
            expect(response).to redirect_to(edit_draft_path(template.draft_belonging_to user))
          end
        end

        context 'without a draft belonging to the current user' do
          it 'redirects to the application path' do
            submit
            expect(response).to redirect_to application_path(template)
          end
        end
      end
    end
  end
end
