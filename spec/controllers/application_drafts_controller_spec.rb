require 'rails_helper'

describe ApplicationDraftsController do
  describe 'DELETE #destroy' do
    before :each do
      @draft = create :application_draft
    end
    let :submit do
      delete :destroy, id: @draft.id
    end
    context 'student' do
      before :each do
        when_current_user_is :student
      end
      it 'does not allow access' do
        expect_any_instance_of(ApplicationDraft)
          .not_to receive :destroy
        submit
        expect(response).to have_http_status :unauthorized
      end
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
      get :edit, id: @draft.id
    end
    context 'student' do
      before :each do
        when_current_user_is :student
      end
      it 'does not allow access' do
        submit
        expect(response).to have_http_status :unauthorized
      end
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
      get :new, application_template_id: @template.id
    end
    context 'student' do
      before :each do
        when_current_user_is :student
      end
      it 'does not allow access' do
        expect_any_instance_of(ApplicationTemplate)
          .not_to receive :create_draft
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        @user = create :user, :staff
        when_current_user_is @user
      end
      context 'no pre-existing draft' do
        it 'creates a draft for the correct application template' do
          expect { submit }
            .to change { @template.drafts.count }
            .by 1
        end
      end
      context 'pre-existing draft' do
        it 'finds the pre-existing draft' do
          draft = create :application_draft,
                         application_template: @template, user: @user
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

  describe 'POST #move_question' do
    before :each do
      @draft = create :application_draft
      @question = create :question, application_draft: @draft
      @direction = :up
    end
    let :submit do
      post :move_question,
           id: @draft.id,
           number: @question.number,
           direction: @direction
    end
    context 'student' do
      before :each do
        when_current_user_is :student
      end
      it 'does not allow access' do
        expect_any_instance_of(ApplicationDraft)
          .not_to receive(:move_question)
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'assigns the correct draft to the draft instance variable' do
        submit
        expect(assigns.fetch :draft).to eql @draft
      end
      it 'calls #move_question on the draft' do
        expect_any_instance_of(ApplicationDraft)
          .to receive(:move_question)
          .with(@question.number, @direction)
        submit
      end
      it 'redirects to the edit path' do
        submit
        expect(response).to redirect_to edit_draft_path(@draft)
      end
    end
  end

  describe 'POST #remove_question' do
    before :each do
      @draft = create :application_draft
      @question = create :question, application_draft: @draft
    end
    let :submit do
      post :remove_question, id: @draft.id, number: @question.number
    end
    context 'student' do
      before :each do
        when_current_user_is :student
      end
      it 'does not allow access' do
        expect_any_instance_of(ApplicationDraft)
          .not_to receive :remove_question
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
    context 'staff' do
      before :each do
        when_current_user_is :staff
      end
      it 'assigns the correct draft to the draft instance variable' do
        submit
        expect(assigns.fetch :draft).to eql @draft
      end
      it 'calls #remove_question on the draft with the number referenced' do
        expect_any_instance_of(ApplicationDraft)
          .to receive(:remove_question)
          .with @question.number
        submit
      end
      it 'redirects to the edit path for the draft' do
        submit
        expect(response).to redirect_to edit_draft_path(@draft)
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
      post :update, id: @draft, draft: @draft_changes, commit: @commit
    end
    context 'student' do
      before :each do
        when_current_user_is :student
      end
      it 'does not allow access' do
        expect_any_instance_of(ApplicationDraft)
          .not_to receive :update_questions
        submit
        expect(response).to have_http_status :unauthorized
      end
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
      post :update_application_template, id: @draft.id
    end
    context 'not staff' do
      before :each do
        when_current_user_is :student
      end
      it 'does not allow access' do
        expect_any_instance_of(ApplicationDraft)
          .not_to receive :update_application_template!
        submit
        expect(response).to have_http_status :unauthorized
      end
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
