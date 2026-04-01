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
    let(:draft) { create(:application_draft) }

    let :submit do
      delete :destroy, params: { id: draft.id }
    end

    context 'when the current user is staff' do
      before do
        when_current_user_is :staff
      end

      it 'assigns the correct draft to the draft instance variable' do
        submit
        expect(assigns.fetch(:draft)).to eq(draft)
      end

      it 'destroys the draft' do
        allow(ApplicationDraft).to receive_messages(includes: ApplicationDraft, find: draft)
        allow(draft).to receive(:destroy)
        submit
        expect(draft).to have_received(:destroy)
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
    let(:draft) { create(:application_draft) }

    let :submit do
      get :edit, params: { id: draft.id }
    end

    context 'when the current user is staff' do
      before do
        when_current_user_is :staff
      end

      it 'assigns the correct draft to the draft instance variable' do
        submit
        expect(assigns.fetch(:draft)).to eq(draft)
      end

      it 'adds a question to the draft, in memory only' do
        submit
        expect(assigns.fetch(:draft).questions.size).to be(1)
      end

      it 'does not persist the new question' do
        # Factory draft has 0 questions by default
        expect { submit }.not_to(change { draft.questions.count })
      end

      it 'renders the edit template' do
        submit
        expect(response).to render_template 'edit'
      end
    end
  end

  describe 'GET #new' do
    let(:template) { create(:application_template) }

    let :submit do
      get :new, params: { application_template_id: template.id }
    end

    context 'when the current user is staff' do
      let(:user) { create(:user, :staff) }

      before { when_current_user_is user }

      context 'with no pre-existing draft' do
        it 'creates a draft for the correct application template' do
          expect { submit }.to change { template.drafts.count }.by(1)
        end
      end

      context 'with a pre-existing draft' do
        it 'finds the pre-existing draft' do
          draft = create(:application_draft, application_template: template, user:)
          submit
          expect(assigns.fetch(:draft)).to eq(draft)
        end
      end

      it 'redirects to the edit page for that draft' do
        submit
        draft = assigns.fetch :draft
        expect(response).to redirect_to(edit_draft_path(draft))
      end
    end
  end

  describe 'POST #update' do
    let(:draft) { create(:application_draft) }
    let(:draft_changes) do
      { questions_attributes: { '0' => { number: 1, data_type: 'text', prompt: 'a_prompt' } } }
    end
    let(:commit) { 'Save changes and continue editing' }

    let :submit do
      post :update, params: { id: draft, draft: draft_changes, commit: }
    end

    context 'when current user is staff' do
      before do
        when_current_user_is :staff
      end

      it 'assigns the correct draft variable' do
        submit
        expect(assigns.fetch(:draft)).to eq(draft)
      end

      it 'updates the draft with the changes given' do
        submit
        expect(draft.reload.questions.first.prompt).to eq('a_prompt')
      end

      context 'when saving changes' do
        it 'redirects to the edit page for the draft' do
          submit
          expect(response).to redirect_to(edit_draft_path(draft))
        end
      end

      context 'when previewing changes' do
        let(:commit) { 'Preview changes' }

        it 'renders the show page' do
          submit
          expect(response).to render_template('show')
        end
      end
    end
  end

  describe 'POST #update_application_template' do
    let(:draft) { create(:application_draft) }

    let :submit do
      post :update_application_template, params: { id: draft.id }
    end

    context 'when the current user is staff' do
      before do
        when_current_user_is :staff
      end

      it 'assigns the correct draft to the draft instance variable' do
        submit
        expect(assigns.fetch(:draft)).to eq(draft)
      end

      it 'calls update_application_template! on the draft' do
        allow(ApplicationDraft).to receive_messages(includes: ApplicationDraft, find: draft)
        allow(draft).to receive(:update_application_template!)
        submit
        expect(draft).to have_received(:update_application_template!)
      end

      it 'includes a flash message' do
        submit
        expect(flash[:message]).not_to be_empty
      end

      it 'redirects to the staff dashboard' do
        submit
        expect(response).to redirect_to(staff_dashboard_url)
      end
    end
  end
end
