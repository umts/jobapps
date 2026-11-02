# frozen_string_literal: true

require 'rails_helper'

describe 'Positions' do
  let(:position) { create(:position) }

  shared_examples 'a forbidden position request' do |role|
    context "with #{role} privilege" do
      before { when_current_user_is role }

      it 'returns forbidden' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /positions/new' do
    subject(:submit) { get '/positions/new' }

    shared_examples 'an authorized position creator' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'returns a successful response' do
          submit
          expect(response).to have_http_status(:ok)
        end
      end
    end

    it_behaves_like 'an authorized position creator', :staff
    it_behaves_like 'an authorized position creator', :admin
    it_behaves_like 'a forbidden position request', :student
  end

  describe 'POST /positions' do
    subject(:submit) { post '/positions', params: { position: attributes } }

    let(:department) { create(:department) }
    let(:valid_attributes) { attributes_for(:position).merge(department_id: department.id) }
    let(:attributes) { valid_attributes }

    shared_examples 'an authorized position creator' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        context 'with valid attributes' do
          it 'creates a position' do
            expect { submit }.to change(Position, :count).by(1)
          end

          it 'creates a position with the given attributes' do
            submit
            created = Position.find_by!(name: attributes[:name])
            expect(created).to have_attributes(attributes)
          end

          it 'redirects to the staff dashboard' do
            submit
            expect(response).to redirect_to(staff_dashboard_path)
          end
        end

        context 'with invalid attributes' do
          let(:attributes) { valid_attributes.merge(name: nil) }

          it 'does not create a position' do
            expect { submit }.not_to change(Position, :count)
          end

          it 'redirects to the root path' do
            submit
            expect(response).to redirect_to(root_path)
          end
        end

        context 'without position params' do
          subject(:submit) { post '/positions' }

          it 'returns bad request' do
            submit
            expect(response).to have_http_status(:bad_request)
          end
        end
      end
    end

    it_behaves_like 'an authorized position creator', :staff
    it_behaves_like 'an authorized position creator', :admin
    it_behaves_like 'a forbidden position request', :student
  end

  describe 'GET /positions/:id/edit' do
    subject(:submit) { get "/positions/#{position.id}/edit" }

    shared_examples 'an authorized position editor' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'returns a successful response' do
          submit
          expect(response).to have_http_status(:ok)
        end
      end
    end

    it_behaves_like 'an authorized position editor', :staff
    it_behaves_like 'an authorized position editor', :admin
    it_behaves_like 'a forbidden position request', :student
  end

  describe 'PUT /positions/:id' do
    subject(:submit) { put "/positions/#{position.id}", params: { position: attributes } }

    let(:attributes) { { name: 'Updated name', default_interview_location: 'Updated place' } }

    shared_examples 'an authorized position updater' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        context 'with valid attributes' do
          it 'updates the position with the given attributes' do
            submit
            expect(position.reload).to have_attributes(attributes)
          end

          it 'redirects to the staff dashboard' do
            submit
            expect(response).to redirect_to(staff_dashboard_path)
          end
        end

        context 'with invalid attributes' do
          let(:attributes) { { name: nil } }

          it 'does not update the position' do
            expect { submit }.not_to(change { position.reload.name })
          end

          it 'redirects to the root path' do
            submit
            expect(response).to redirect_to(root_path)
          end
        end

        context 'without position params' do
          subject(:submit) { put "/positions/#{position.id}" }

          it 'returns bad request' do
            submit
            expect(response).to have_http_status(:bad_request)
          end
        end
      end
    end

    it_behaves_like 'an authorized position updater', :staff
    it_behaves_like 'an authorized position updater', :admin
    it_behaves_like 'a forbidden position request', :student
  end

  describe 'DELETE /positions/:id' do
    subject(:submit) { delete "/positions/#{position.id}" }

    shared_examples 'an authorized position destroyer' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'destroys the position' do
          position
          expect { submit }.to change(Position, :count).by(-1)
        end

        it 'redirects to the staff dashboard' do
          submit
          expect(response).to redirect_to(staff_dashboard_path)
        end
      end
    end

    it_behaves_like 'an authorized position destroyer', :staff
    it_behaves_like 'an authorized position destroyer', :admin
    it_behaves_like 'a forbidden position request', :student
  end

  describe 'GET /positions/:id/saved_applications' do
    subject(:submit) { get "/positions/#{position.id}/saved_applications" }

    shared_examples 'an authorized saved applications viewer' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'returns a successful response' do
          submit
          expect(response).to have_http_status(:ok)
        end
      end
    end

    it_behaves_like 'an authorized saved applications viewer', :staff
    it_behaves_like 'an authorized saved applications viewer', :admin
    it_behaves_like 'a forbidden position request', :student
  end
end
