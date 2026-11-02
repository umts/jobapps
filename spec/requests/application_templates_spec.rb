# frozen_string_literal: true

require 'rails_helper'

describe 'ApplicationTemplates' do
  let(:template) { create(:application_template) }

  shared_examples 'a forbidden template request' do |role|
    context "with #{role} privilege" do
      before { when_current_user_is role }

      it 'returns forbidden' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  shared_examples 'an authorized template setting toggler' do |role, attribute|
    context "with #{role} privilege" do
      let(:user) { create(:user, role) }

      before { when_current_user_is user }

      context "with #{attribute} disabled" do
        before { template.update attribute => false }

        it "enables #{attribute}" do
          submit
          expect(template.reload.public_send(attribute)).to be true
        end
      end

      context "with #{attribute} enabled" do
        before { template.update attribute => true }

        it "disables #{attribute}" do
          submit
          expect(template.reload.public_send(attribute)).to be false
        end
      end

      context 'without a draft belonging to the current user' do
        it 'redirects to the application page' do
          submit
          expect(response).to redirect_to(application_path(template))
        end
      end

      context 'with a draft belonging to the current user' do
        before { template.create_draft user }

        it 'redirects to the edit page for the draft' do
          submit
          expect(response).to redirect_to(edit_draft_path(template.draft_belonging_to(user)))
        end
      end
    end
  end

  describe 'GET /applications/new' do
    subject(:submit) { get '/applications/new', params: params }

    let(:position) { create(:position) }
    let(:params) { { position_id: position.id } }

    shared_examples 'an authorized template creator' do |role|
      context "with #{role} privilege" do
        let(:user) { create(:user, role) }

        before { when_current_user_is user }

        it 'creates an application template for the position' do
          expect { submit }.to change { position.reload.application_template }
            .from(nil).to(be_a(ApplicationTemplate))
        end

        it 'creates a draft for the current user' do
          submit
          expect(position.reload.application_template.drafts.last.user).to eq(user)
        end

        it 'redirects to the edit page for that draft' do
          submit
          draft = position.reload.application_template.drafts.last
          expect(response).to redirect_to(edit_draft_path(draft))
        end

        context 'without a position id' do
          let(:params) { {} }

          it 'returns bad request' do
            submit
            expect(response).to have_http_status(:bad_request)
          end
        end
      end
    end

    it_behaves_like 'an authorized template creator', :staff
    it_behaves_like 'an authorized template creator', :admin
    it_behaves_like 'a forbidden template request', :student
  end

  describe 'GET /applications/:id' do
    subject(:submit) { get "/applications/#{template.slug}", params: params }

    let(:params) { {} }

    shared_examples 'an authorized template viewer' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'returns a successful response' do
          submit
          expect(response).to have_http_status(:ok)
        end

        context 'with a submission to preload from' do
          let(:record) { create(:application_submission, data: [['a question', 'an answer', 'data type', 1]]) }
          let(:params) { { load_id: record.id } }

          it 'returns a successful response' do
            submit
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end

    it_behaves_like 'an authorized template viewer', :student
    it_behaves_like 'an authorized template viewer', :staff
    it_behaves_like 'an authorized template viewer', :admin
  end

  describe 'POST /applications/:id/toggle_active' do
    subject(:submit) { post "/applications/#{template.id}/toggle_active" }

    shared_examples 'an authorized template activation toggler' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        context 'with the template inactive' do
          before { template.update active: false }

          it 'marks the template as active' do
            submit
            expect(template.reload.active).to be true
          end
        end

        context 'with the template active' do
          before { template.update active: true }

          it 'marks the template as inactive' do
            submit
            expect(template.reload.active).to be false
          end
        end

        it 'redirects to the application page' do
          submit
          expect(response).to redirect_to(application_path(template))
        end
      end
    end

    it_behaves_like 'an authorized template activation toggler', :staff
    it_behaves_like 'an authorized template activation toggler', :admin
    it_behaves_like 'a forbidden template request', :student
  end

  describe 'POST /applications/:id/toggle_eeo_enabled' do
    subject(:submit) { post "/applications/#{template.id}/toggle_eeo_enabled" }

    it_behaves_like 'an authorized template setting toggler', :staff, :eeo_enabled
    it_behaves_like 'an authorized template setting toggler', :admin, :eeo_enabled
    it_behaves_like 'a forbidden template request', :student
  end

  describe 'POST /applications/:id/toggle_unavailability_enabled' do
    subject(:submit) { post "/applications/#{template.id}/toggle_unavailability_enabled" }

    it_behaves_like 'an authorized template setting toggler', :staff, :unavailability_enabled
    it_behaves_like 'an authorized template setting toggler', :admin, :unavailability_enabled
    it_behaves_like 'a forbidden template request', :student
  end

  describe 'POST /applications/:id/toggle_resume_upload_enabled' do
    subject(:submit) { post "/applications/#{template.id}/toggle_resume_upload_enabled" }

    it_behaves_like 'an authorized template setting toggler', :staff, :resume_upload_enabled
    it_behaves_like 'an authorized template setting toggler', :admin, :resume_upload_enabled
    it_behaves_like 'a forbidden template request', :student
  end
end
