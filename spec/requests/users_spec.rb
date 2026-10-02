# frozen_string_literal: true

require 'rails_helper'

describe 'UsersController' do
  shared_context 'with invalid attributes' do
    let(:attributes) { attributes_for(:user, email: nil, last_name: nil) }
  end

  shared_examples 'a forbidden user-management request' do |role|
    context "with #{role} privilege" do
      before { when_current_user_is role }

      it 'returns forbidden' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /users/new' do
    subject(:submit) { get '/users/new' }

    it_behaves_like 'a forbidden user-management request', :staff
    it_behaves_like 'a forbidden user-management request', :student

    context 'with admin privileges' do
      before { when_current_user_is :admin }

      it 'returns a successful response' do
        submit
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /users' do
    subject(:submit) { post '/users', params: { user: attributes } }

    let(:attributes) { attributes_for(:user) }

    context 'with admin privileges' do
      before { when_current_user_is :admin }

      context 'with correct attributes' do
        it 'creates a user' do
          expect { submit }.to change(User, :count).by(1)
        end

        it 'creates user with given attributes' do
          submit
          user = User.find_by(entra_uid: attributes[:entra_uid])
          expect(user).to have_attributes(attributes)
        end

        it 'redirects to the staff dashboard' do
          submit
          expect(response).to redirect_to(staff_dashboard_path)
        end

        it 'responds with a success message' do
          submit
          expect(flash[:message]).to eq(I18n.t('users.create.success'))
        end
      end

      context 'with invalid attributes' do
        include_context 'with invalid attributes'

        it 'does not create a user' do
          expect { submit }.not_to change(User, :count)
        end

        it 'responds with validation errors' do
          submit
          expect(flash[:errors]).to eq(['Email can\'t be blank', 'Last name can\'t be blank', 'Email is invalid'])
        end
      end
    end

    it_behaves_like 'a forbidden user-management request', :staff
    it_behaves_like 'a forbidden user-management request', :student
  end

  describe 'PATCH /users' do
    subject(:submit) { patch "/users/#{user.id}", params: { user: attributes } }

    let(:user) { create(:user) }
    let(:attributes) { attributes_for(:user) }

    context 'with admin privileges' do
      before { when_current_user_is :admin }

      context 'with correct attributes' do
        it 'updates the user with given attributes' do
          submit
          expect(user.reload).to have_attributes(attributes)
        end

        it 'redirects to the staff dashboard' do
          submit
          expect(response).to redirect_to(staff_dashboard_path)
        end

        it 'responds with a success message' do
          submit
          expect(flash[:message]).to eq(I18n.t('users.update.success'))
        end
      end

      context 'with invalid attributes' do
        include_context 'with invalid attributes'

        it 'responds with validation errors' do
          submit
          expect(flash[:errors]).to eq(['Email can\'t be blank', 'Last name can\'t be blank', 'Email is invalid'])
        end

        it 'does not update the user' do
          original_attributes = user.attributes.slice('email', 'last_name', 'first_name', 'entra_uid', 'staff')
          submit
          expect(user.reload.slice(*original_attributes.keys)).to eq(original_attributes)
        end
      end
    end

    it_behaves_like 'a forbidden user-management request', :staff
    it_behaves_like 'a forbidden user-management request', :student
  end

  describe 'GET /users/:id/edit' do
    subject(:submit) { get "/users/#{user.id}/edit" }

    let(:user) { create(:user) }

    context 'with admin privileges' do
      before { when_current_user_is :admin }

      it 'returns success' do
        submit
        expect(response).to have_http_status(:ok)
      end
    end

    it_behaves_like 'a forbidden user-management request', :staff
    it_behaves_like 'a forbidden user-management request', :student
  end

  describe 'DELETE /users/:id' do
    subject(:submit) { delete "/users/#{user.id}" }

    let(:user) { create(:user) }

    it_behaves_like 'a forbidden user-management request', :staff
    it_behaves_like 'a forbidden user-management request', :student

    context 'with admin privileges' do
      before { when_current_user_is :admin }

      it 'destroys the user' do
        submit
        expect { user.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'redirects to the staff dashboard' do
        submit
        expect(response).to redirect_to(staff_dashboard_path)
      end

      it 'responds with a success message' do
        submit
        expect(flash[:message]).to eq(I18n.t('users.destroy.success'))
      end
    end
  end

  describe 'GET /users/promote' do
    subject(:submit) { get '/users/promote' }

    it_behaves_like 'a forbidden user-management request', :staff
    it_behaves_like 'a forbidden user-management request', :student

    context 'with admin privileges' do
      before { when_current_user_is :admin }

      let!(:user) { create(:user, staff: false) }
      let!(:staff_user) { create(:user, staff: true) }

      it 'returns a list of users who are not staff' do
        submit
        expect(response.body).to include("#{user.first_name} #{user.last_name} #{user.id}")
      end

      it 'does not include staff users' do
        submit
        expect(response.body).not_to include("#{staff_user.first_name} #{staff_user.last_name} #{staff_user.id}")
      end
    end
  end

  describe 'PUT /users/promote_save' do
    subject(:submit) { put '/users/promote_save', params: { user: selection } }

    let(:selection) { "#{user.first_name} #{user.last_name} #{user.id}" }
    let(:user) { create(:user, staff: false) }

    it_behaves_like 'a forbidden user-management request', :staff
    it_behaves_like 'a forbidden user-management request', :student

    context 'with admin privileges' do
      before { when_current_user_is :admin }

      it 'promotes the user to staff' do
        submit
        expect(user.reload.staff).to be true
      end

      it 'redirects to the promote users page' do
        submit
        expect(response).to redirect_to(promote_users_path)
      end

      it 'responds with a success message' do
        submit
        expect(flash[:message]).to eq(I18n.t('users.promote_save.success'))
      end

      context 'with an unknown user' do
        let(:selection) { 'Unknown User 100000' }

        it 'redirects to the promote users page' do
          submit
          expect(response).to redirect_to(promote_users_path)
        end

        it 'does not respond with a success message' do
          submit
          expect(flash[:message]).to be_nil
        end
      end

      context 'with no selected user' do
        let(:selection) { '' }

        it 'redirects to the promote users page' do
          submit
          expect(response).to redirect_to(promote_users_path)
        end

        it 'does not respond with a success message' do
          submit
          expect(flash[:message]).to be_nil
        end
      end
    end
  end
end
