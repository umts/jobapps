# frozen_string_literal: true

require 'rails_helper'

describe ApplicationDraftsController do
  it_behaves_like 'an access-controlled resource', routes: [
    %i[delete destroy member],
    %i[get edit member],
    %i[get new collection],
    %i[post update member],
    %i[post update_application_template member]
  ]
  describe 'DELETE #destroy' do
    before :each do
      @draft = create :application_draft
    end
    let :submit do
      delete :destroy, params: { id: @draft.id }
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'assigns the correct draft to the draft instance variable' do
        submit
        expect(assigns.fetch :draft).to eql @draft
      end
      it 'destroys the draft' do
        expect_any_instance_of(ApplicationDraft)
          .to receive :destroy
        submit
      end
      it 'includes a flash message' do
        submit
        expect(flash[:message]).not_to be_empty
      end
      it 'redirects to the staff dashboard' do
        submit
        expect(response).to redirect_to staff_dashboard_url
      end
    end
  end

  describe 'GET #edit' do
    before :each do
      @draft = create :application_draft
    end
    let :submit do
      get :edit, params: { id: @draft.id }
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'assigns the correct draft to the draft instance variable' do
        submit
        expect(assigns.fetch :draft).to eql @draft
      end
      it 'adds a question to the draft, in memory only' do
        expect { submit }
          .not_to change { @draft.questions.count }
        # Factory draft has 0 questions by default
        expect(assigns.fetch(:draft).questions.size).to be 1
      end
      it 'renders the edit template' do
        submit
        expect(response).to render_template 'edit'
      end
    end
  end
  describe 'GET #new' do
    before :each do
      @template = create :application_template
    end
    let :submit do
      get :new, params: { application_template_id: @template.id }
    end
    context 'staff' do
      before :each do
        @user = create :user, :staff
        when_current_user_is @user
      end
      context 'no pre-existing draft' do
        it 'creates a draft for the correct application template' do
          expect { submit }
            .to change { ApplicationDraft.where(application_template: @template).count }.by 1
        end
      end
      context 'pre-existing draft' do
        it 'finds the pre-existing draft' do
          draft = create :application_draft, application_template: @template, locked_by: @user
          submit
          expect(assigns.fetch :draft).to eql draft
        end
      end
      it 'redirects to the edit page for that draft' do
        submit
        draft = assigns.fetch :draft
        expect(response).to redirect_to edit_draft_path(draft)
      end
    end
  end

  describe 'POST #update' do
    before :each do
      @draft = create :application_draft
      @question_attrs = { a_key: 'a_value' }
      @draft_changes = { questions_attributes: @question_attrs }
      @commit = 'Save changes and continue editing'
    end
    let :submit do
      post :update, params: {
        id: @draft,
        draft: @draft_changes,
        commit: @commit
      }
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
        # Mock it out above so that we don't get errors
        # from the original method being invoked
        # on an incorrect data structure
        expect_any_instance_of(ApplicationDraft)
          .to receive(:update_questions)
          .with @question_attrs.stringify_keys
      end
      it 'assigns the correct draft variable' do
        submit
        expect(assigns.fetch :draft).to eql @draft
      end
      it 'updates the draft with the changes given' do
        # mocked above
        submit
      end
      context 'saving changes' do
        it 'redirects to the edit page for the draft' do
          submit
          expect(response).to redirect_to edit_draft_path(@draft)
        end
      end
      context 'previewing changes' do
        it 'renders the show page' do
          @commit = 'Preview changes'
          submit
          expect(response).to render_template 'show'
        end
      end
    end
  end

  describe 'POST #update_application_template' do
    before :each do
      @draft = create :application_draft
    end
    let :submit do
      post :update_application_template, params: { id: @draft.id }
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'assigns the correct draft to the draft instance variable' do
        submit
        expect(assigns.fetch :draft).to eql @draft
      end
      it 'calls update_application_template! on the draft' do
        expect_any_instance_of(ApplicationDraft)
          .to receive :update_application_template!
        submit
      end
      it 'includes a flash message' do
        submit
        expect(flash[:message]).not_to be_empty
      end
      it 'redirects to the staff dashboard' do
        submit
        expect(response).to redirect_to staff_dashboard_url
      end
    end
  end
end
