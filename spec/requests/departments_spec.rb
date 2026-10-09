# frozen_string_literal: true

require 'rails_helper'

describe 'Departments' do
  shared_examples 'an unauthorized department manager' do
    context 'with student privilege' do
      before { when_current_user_is :student }

      it 'returns forbidden' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /departments/new' do
    subject(:submit) { get '/departments/new' }

    shared_examples 'an authorized department manager' do
      %i[staff admin].each do |role|
        context "with #{role} privilege" do
          before { when_current_user_is role }

          it 'returns ok' do
            submit
            expect(response).to have_http_status(:ok)
          end
        end
      end
    end

    it_behaves_like 'an authorized department manager'
    it_behaves_like 'an unauthorized department manager'
  end

  describe 'POST /departments' do
    subject(:submit) do
      post '/departments', params: { department: attributes }
    end

    let(:valid_attributes) { attributes_for(:department) }
    let(:attributes) { valid_attributes }

    shared_examples 'an authorized department manager' do
      %i[staff admin].each do |role|
        context "with #{role} privilege" do
          before { when_current_user_is role }

          context 'with valid attributes' do
            it 'creates a department' do
              expect { submit }.to change(Department, :count).by(1)
            end

            it 'creates a department with the given attributes' do
              submit
              expect(Department.find_by!(name: attributes[:name])).to have_attributes(attributes)
            end

            it 'sets the success message' do
              submit
              expect(flash[:message]).to eq(I18n.t('departments.create.success'))
            end

            it 'redirects to the staff dashboard' do
              submit
              expect(response).to redirect_to(staff_dashboard_path)
            end
          end

          context 'with invalid attributes' do
            let(:attributes) { valid_attributes.merge(name: nil) }

            it 'does not create a department' do
              expect { submit }.not_to change(Department, :count)
            end

            it 'sets the error messages' do
              submit
              expect(flash[:errors]).to be_present
            end

            it 'redirects back' do
              submit
              expect(response).to redirect_to(root_path)
            end
          end
        end
      end
    end

    it_behaves_like 'an authorized department manager'
    it_behaves_like 'an unauthorized department manager'
  end

  describe 'GET /departments/:id/edit' do
    subject(:submit) { get "/departments/#{department.id}/edit" }

    let(:department) { create(:department) }

    shared_examples 'an authorized department manager' do
      %i[staff admin].each do |role|
        context "with #{role} privilege" do
          before { when_current_user_is role }

          it 'returns ok' do
            submit
            expect(response).to have_http_status(:ok)
          end

          it 'displays the department name' do
            submit
            expect(response.body).to include(department.name)
          end
        end
      end
    end

    it_behaves_like 'an authorized department manager'
    it_behaves_like 'an unauthorized department manager'
  end

  describe 'PATCH /departments/:id' do
    subject(:submit) do
      patch "/departments/#{department.id}", params: { department: attributes }
    end

    let(:department) { create(:department, name: 'Old Name') }
    let(:attributes) { { name: 'New Name' } }

    shared_examples 'an authorized department manager' do
      %i[staff admin].each do |role|
        context "with #{role} privilege" do
          before { when_current_user_is role }

          context 'with valid attributes' do
            it 'updates the department' do
              expect { submit }.to change { department.reload.name }.from('Old Name').to('New Name')
            end

            it 'sets the success message' do
              submit
              expect(flash[:message]).to eq(I18n.t('departments.update.success'))
            end

            it 'redirects to the staff dashboard' do
              submit
              expect(response).to redirect_to(staff_dashboard_path)
            end
          end

          context 'with invalid attributes' do
            let(:attributes) { { name: nil } }

            it 'does not update the department' do
              expect { submit }.not_to(change { department.reload.name })
            end

            it 'sets the error messages' do
              submit
              expect(flash[:errors]).to be_present
            end

            it 'redirects back' do
              submit
              expect(response).to redirect_to(root_path)
            end
          end
        end
      end
    end

    it_behaves_like 'an authorized department manager'
    it_behaves_like 'an unauthorized department manager'
  end

  describe 'DELETE /departments/:id' do
    subject(:submit) { delete "/departments/#{department.id}" }

    let!(:department) { create(:department) }

    shared_examples 'an authorized department manager' do
      %i[staff admin].each do |role|
        context "with #{role} privilege" do
          before { when_current_user_is role }

          it 'destroys the department' do
            expect { submit }.to change(Department, :count).by(-1)
          end

          it 'sets the success message' do
            submit
            expect(flash[:message]).to eq(I18n.t('departments.destroy.success'))
          end

          it 'redirects to the staff dashboard' do
            submit
            expect(response).to redirect_to(staff_dashboard_path)
          end
        end
      end
    end

    it_behaves_like 'an authorized department manager'
    it_behaves_like 'an unauthorized department manager'
  end
end
