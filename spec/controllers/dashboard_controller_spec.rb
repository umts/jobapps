# frozen_string_literal: true

require 'rails_helper'

describe DashboardController do
  describe 'GET #main' do
    it 'redirects to staff dashboard for managers' do
      when_current_user_is :manager
      get :main
      expect(response).to redirect_to staff_dashboard_path
    end

    it 'redirects to student dashboard for users who manage no positions' do
      when_current_user_is :anyone
      get :main
      expect(response).to redirect_to student_dashboard_path
    end

    it 'denies access with no user' do
      when_current_user_is nil
      expect { get :main }.to raise_error(ActionPolicy::Unauthorized)
    end
  end

  describe 'GET #staff' do
    let(:submit) { get :staff }

    context 'when the current user manages no positions' do
      before { when_current_user_is :anyone }

      it 'does not allow access' do
        expect { submit }.to raise_error(ActionPolicy::Unauthorized)
      end

      context 'with an XHR request' do
        let(:submit) { get :staff, xhr: true }

        it 'does not allow access' do
          expect { submit }.to raise_error(ActionPolicy::Unauthorized)
        end
      end
    end

    context 'when the current user is a manager' do
      let(:position) { create(:position) }

      before { when_current_user_is create(:user, :manager, managing: position) }

      it 'assigns the required instance variables' do
        submit
        expect(assigns.keys).to include('pending_interviews', 'pending_records', 'positions')
      end

      it 'only includes pending applications for the positions they manage' do
        create(:application_submission, position:)
        create(:application_submission)
        submit
        expect(assigns[:pending_records].keys).to contain_exactly(position)
      end

      context 'with saved applications, interviews and templates for several positions' do
        before do
          [position, create(:position)].each do |p|
            create(:application_submission, position: p, saved_for_later: true, note_for_later: 'later')
            create(:interview, application_submission: create(:application_submission, position: p))
            create(:application_template, position: p)
          end
        end

        it 'only includes the ones for the positions they manage' do
          submit
          expect(assigns.values_at(:saved_records, :pending_interviews, :templates).map(&:keys))
            .to all(contain_exactly(position))
        end
      end
    end
  end

  describe 'GET #student' do
    let(:submit) { get :student }

    context 'with no user' do
      before { when_current_user_is nil }

      it 'denies access' do
        when_current_user_is nil
        expect { get :main }.to raise_error(ActionPolicy::Unauthorized)
      end
    end

    context 'when the current user manages no positions' do
      before { when_current_user_is :anyone }

      it 'allows access' do
        submit
        expect(response).not_to have_http_status :unauthorized
      end

      it 'assigns the required instance variables' do
        submit
        expect(assigns.keys).to include('application_submissions', 'interviews', 'positions')
      end
    end
  end
end
