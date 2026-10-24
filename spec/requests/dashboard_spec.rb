# frozen_string_literal: true

require 'rails_helper'

describe 'Dashboard' do
  shared_examples 'a forbidden dashboard request' do |role|
    context "with #{role} privilege" do
      before { when_current_user_is role }

      it 'returns forbidden' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  shared_examples 'a dashboard redirect' do |role, dashboard_name|
    context "with #{role} privilege" do
      before { when_current_user_is role }

      it "redirects to the #{dashboard_name} dashboard" do
        submit
        expect(response).to redirect_to(public_send("#{dashboard_name}_dashboard_path"))
      end
    end
  end

  describe 'GET /dashboard/main' do
    subject(:submit) { get '/dashboard/main' }

    it_behaves_like 'a dashboard redirect', :staff, :staff
    it_behaves_like 'a dashboard redirect', :admin, :staff
    it_behaves_like 'a dashboard redirect', :student, :student
  end

  describe 'GET /' do
    subject(:submit) { get '/' }

    it_behaves_like 'a dashboard redirect', :staff, :staff
    it_behaves_like 'a dashboard redirect', :admin, :staff
    it_behaves_like 'a dashboard redirect', :student, :student
  end

  describe 'GET /dashboard/staff' do
    subject(:submit) { get '/dashboard/staff' }

    shared_examples 'an authorized staff dashboard viewer' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'returns a successful response' do
          submit
          expect(response).to have_http_status(:ok)
        end

        context 'with existing records' do
          before do
            create(:interview)
            create(:application_submission)
            create(:application_submission, saved_for_later: true, note_for_later: 'A note')
            create(:application_template)
          end

          it 'returns a successful response' do
            submit
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end

    it_behaves_like 'an authorized staff dashboard viewer', :staff
    it_behaves_like 'an authorized staff dashboard viewer', :admin
    it_behaves_like 'a forbidden dashboard request', :student
  end

  describe 'GET /dashboard/student' do
    subject(:submit) { get '/dashboard/student' }

    shared_examples 'an authorized student dashboard viewer' do |role|
      context "with #{role} privilege" do
        let(:user) { create(:user, role) }

        before { when_current_user_is user }

        it 'returns a successful response' do
          submit
          expect(response).to have_http_status(:ok)
        end

        context 'with existing records' do
          before do
            application_submission = create(:application_submission, user:)
            create(:interview, user:, application_submission:)
          end

          it 'returns a successful response' do
            submit
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end

    it_behaves_like 'an authorized student dashboard viewer', :student
    it_behaves_like 'an authorized student dashboard viewer', :staff
    it_behaves_like 'an authorized student dashboard viewer', :admin
  end
end
