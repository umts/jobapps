# frozen_string_literal: true

require 'rails_helper'

describe 'ApplicationDrafts' do
  let(:draft) { create(:application_draft) }

  shared_examples 'a forbidden draft request' do |role|
    context "with #{role} privilege" do
      before { when_current_user_is role }

      it 'returns forbidden' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /application_drafts/:id' do
    subject(:submit) { get "/application_drafts/#{draft.id}" }

    shared_examples 'an authorized draft viewer' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'returns a successful response' do
          submit
          expect(response).to have_http_status(:ok)
        end
      end
    end

    it_behaves_like 'an authorized draft viewer', :staff
    it_behaves_like 'an authorized draft viewer', :admin
    it_behaves_like 'a forbidden draft request', :student
  end

  describe 'GET /application_drafts/new' do
    subject(:submit) { get '/application_drafts/new', params: params }

    let(:template) { create(:application_template) }
    let(:params) { { application_template_id: template.id } }

    shared_examples 'an authorized draft creator' do |role|
      context "with #{role} privilege" do
        let(:user) { create(:user, role) }

        before { when_current_user_is user }

        context 'with no pre-existing draft' do
          it 'creates a draft for the application template' do
            expect { submit }.to change { template.drafts.count }.by(1)
          end

          it 'creates the draft for the current user' do
            submit
            expect(template.drafts.last.user).to eq(user)
          end

          it 'redirects to the edit page for that draft' do
            submit
            expect(response).to redirect_to(edit_draft_path(template.drafts.last))
          end
        end

        context 'with a pre-existing draft' do
          let!(:existing_draft) { create(:application_draft, application_template: template, user:) }

          it 'does not create another draft' do
            expect { submit }.not_to(change { template.drafts.count })
          end

          it 'redirects to the edit page for the existing draft' do
            submit
            expect(response).to redirect_to(edit_draft_path(existing_draft))
          end
        end

        context 'without an application template id' do
          let(:params) { {} }

          it 'returns bad request' do
            submit
            expect(response).to have_http_status(:bad_request)
          end
        end
      end
    end

    it_behaves_like 'an authorized draft creator', :staff
    it_behaves_like 'an authorized draft creator', :admin
    it_behaves_like 'a forbidden draft request', :student
  end

  describe 'GET /application_drafts/:id/edit' do
    subject(:submit) { get "/application_drafts/#{draft.id}/edit" }

    shared_examples 'an authorized draft editor' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'returns a successful response' do
          submit
          expect(response).to have_http_status(:ok)
        end
      end
    end

    it_behaves_like 'an authorized draft editor', :staff
    it_behaves_like 'an authorized draft editor', :admin
    it_behaves_like 'a forbidden draft request', :student
  end

  describe 'PATCH /application_drafts/:id' do
    subject(:submit) { patch "/application_drafts/#{draft.id}", params: { draft: draft_changes, commit: commit } }

    let(:draft_changes) do
      {
        email: 'drafts@example.com',
        questions_attributes: { '0' => { number: 1, data_type: 'text', prompt: 'a_prompt', required: false } }
      }
    end
    let(:commit) { 'Save changes and continue editing' }

    shared_examples 'an authorized draft updater' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'updates the draft email' do
          submit
          expect(draft.reload.email).to eq('drafts@example.com')
        end

        it 'creates the questions given' do
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

          it 'returns a successful response' do
            submit
            expect(response).to have_http_status(:ok)
          end
        end

        context 'without a commit value' do
          subject(:submit) { patch "/application_drafts/#{draft.id}", params: { draft: draft_changes } }

          it 'returns bad request' do
            submit
            expect(response).to have_http_status(:bad_request)
          end
        end

        context 'without questions' do
          let(:draft_changes) { { email: 'drafts@example.com' } }

          it 'returns bad request' do
            submit
            expect(response).to have_http_status(:bad_request)
          end
        end
      end
    end

    it_behaves_like 'an authorized draft updater', :staff
    it_behaves_like 'an authorized draft updater', :admin
    it_behaves_like 'a forbidden draft request', :student
  end

  describe 'DELETE /application_drafts/:id' do
    subject(:submit) { delete "/application_drafts/#{draft.id}" }

    shared_examples 'an authorized draft destroyer' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'destroys the draft' do
          draft
          expect { submit }.to change(ApplicationDraft, :count).by(-1)
        end

        it 'redirects to the staff dashboard' do
          submit
          expect(response).to redirect_to(staff_dashboard_path)
        end
      end
    end

    it_behaves_like 'an authorized draft destroyer', :staff
    it_behaves_like 'an authorized draft destroyer', :admin
    it_behaves_like 'a forbidden draft request', :student
  end

  describe 'POST /application_drafts/:id/update_application_template' do
    subject(:submit) { post "/application_drafts/#{draft.id}/update_application_template" }

    let(:draft) { create(:application_draft, email: 'drafts@example.com') }

    shared_examples 'an authorized template updater' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'copies the draft changes to the application template' do
          submit
          expect(draft.application_template.reload.email).to eq('drafts@example.com')
        end

        it 'redirects to the staff dashboard' do
          submit
          expect(response).to redirect_to(staff_dashboard_path)
        end
      end
    end

    it_behaves_like 'an authorized template updater', :staff
    it_behaves_like 'an authorized template updater', :admin
    it_behaves_like 'a forbidden draft request', :student
  end
end
