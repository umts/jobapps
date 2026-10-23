# frozen_string_literal: true

require 'rails_helper'

describe 'Positions' do
  let(:position) { create(:position) }
  let(:manager) { create(:position_manager, position:).user }
  let(:other_manager) { create(:position_manager).user }

  describe 'GET /positions' do
    subject(:submit) do
      get '/positions'
      response
    end

    it { is_expected.to have_http_status(:unauthorized) }

    context 'when logged in as a manager' do
      before do
        create(:position_manager, position: create(:position, name: 'Someone Else'))
        when_current_user_is manager
      end

      it 'lists the positions they manage' do
        expect(submit.body).to include(position.name)
      end

      it 'does not list positions managed by someone else' do
        expect(submit.body).not_to include('Someone Else')
      end
    end

    context 'when logged in as a user who manages nothing' do
      before { when_current_user_is create(:user) }

      it 'lists no positions' do
        position
        expect(submit.body).to include('No positions found')
      end
    end

    context 'when logged in as an admin' do
      before { when_current_user_is :admin }

      it 'lists every position' do
        position
        expect(submit.body).to include(position.name)
      end
    end
  end

  describe 'GET /positions/:id' do
    subject(:submit) do
      get "/positions/#{position.id}"
      response
    end

    it { is_expected.to have_http_status(:unauthorized) }

    context 'when logged in as a manager of a different position' do
      before { when_current_user_is other_manager }

      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'when logged in as a manager of the position' do
      before { when_current_user_is manager }

      it { is_expected.to be_successful }
    end
  end

  describe 'GET /positions/new' do
    subject(:submit) do
      get '/positions/new'
      response
    end

    it { is_expected.to have_http_status(:unauthorized) }

    context 'when logged in as a manager' do
      before { when_current_user_is manager }

      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'when logged in as an admin' do
      before { when_current_user_is :admin }

      it { is_expected.to be_successful }
    end
  end

  describe 'POST /positions' do
    subject(:submit) do
      post '/positions', params: { position: attributes }
      response
    end

    let(:attributes) { { name: 'Operator', default_interview_location: 'Bus Garage', not_hiring_text: 'Soon' } }

    it { is_expected.to have_http_status(:unauthorized) }

    context 'when logged in as a manager' do
      before { when_current_user_is manager }

      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'when logged in as an admin' do
      before { when_current_user_is :admin }

      it 'creates the position with the given attributes' do
        submit
        expect(Position.find_by(name: 'Operator'))
          .to have_attributes(default_interview_location: 'Bus Garage', not_hiring_text: 'Soon')
      end

      it 'redirects to the edit page' do
        expect(submit).to redirect_to(edit_position_path(Position.find_by(name: 'Operator')))
      end

      it 'says the position was created' do
        submit
        expect(flash[:notice]).to eq('Successfully created position')
      end

      context 'with invalid attributes' do
        let(:attributes) { { name: '' } }

        it 'does not create the position' do
          expect { submit }.not_to change(Position, :count)
        end

        it { is_expected.to have_http_status(:unprocessable_content) }
      end
    end
  end

  describe 'GET /positions/:id/edit' do
    subject(:submit) do
      get "/positions/#{position.id}/edit"
      response
    end

    it { is_expected.to have_http_status(:unauthorized) }

    context 'when logged in as a manager of a different position' do
      before { when_current_user_is other_manager }

      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'when logged in as a manager of the position' do
      before { when_current_user_is manager }

      it { is_expected.to be_successful }
    end
  end

  describe 'PATCH /positions/:id' do
    subject(:submit) do
      patch "/positions/#{position.id}", params: { position: attributes }
      response
    end

    let(:attributes) { { name: 'Operator', default_interview_location: 'Bus Garage', not_hiring_text: 'Soon' } }

    it { is_expected.to have_http_status(:unauthorized) }

    context 'when logged in as a manager of a different position' do
      before { when_current_user_is other_manager }

      it { is_expected.to have_http_status(:forbidden) }

      it 'does not update the position' do
        expect { submit }.not_to(change { position.reload.attributes })
      end
    end

    context 'when logged in as a manager of the position' do
      before { when_current_user_is manager }

      it 'updates the position with the given attributes' do
        submit
        expect(position.reload).to have_attributes(attributes)
      end

      it 'redirects to the edit page' do
        expect(submit).to redirect_to(edit_position_path(position))
      end

      it 'says the position was updated' do
        submit
        expect(flash[:notice]).to eq('Successfully updated position')
      end

      context 'with invalid attributes' do
        let(:attributes) { { name: '' } }

        it 'does not update the position' do
          expect { submit }.not_to(change { position.reload.name })
        end

        it { is_expected.to have_http_status(:unprocessable_content) }

        it 'keeps the saved name as the heading' do
          expect(submit.parsed_body.at_css('h1').text).to eq(position.name)
        end
      end
    end
  end

  describe 'DELETE /positions/:id' do
    subject(:submit) do
      delete "/positions/#{position.id}"
      response
    end

    it { is_expected.to have_http_status(:unauthorized) }

    context 'when logged in as a manager of a different position' do
      before { when_current_user_is other_manager }

      it { is_expected.to have_http_status(:forbidden) }

      it 'does not delete the position' do
        position
        expect { submit }.not_to change(Position, :count)
      end
    end

    context 'when logged in as a manager of the position' do
      before { when_current_user_is manager }

      it 'deletes the position' do
        expect { submit }.to change(Position, :count).by(-1)
      end

      it 'redirects to the positions list' do
        expect(submit).to redirect_to(positions_path)
      end

      it 'says the position was deleted' do
        submit
        expect(flash[:notice]).to eq('Successfully deleted position')
      end

      context 'when the position has applications' do
        before { create(:application_submission, position:) }

        it 'does not delete the position' do
          expect { submit }.not_to change(Position, :count)
        end

        it 'redirects back to the position' do
          expect(submit).to redirect_to(position_path(position))
        end

        it 'says why it was not deleted' do
          submit
          expect(flash[:alert]).to include('application submissions')
        end
      end
    end
  end

  describe 'GET /positions/:id/saved_applications' do
    subject(:submit) do
      get "/positions/#{position.id}/saved_applications"
      response
    end

    it { is_expected.to have_http_status(:unauthorized) }

    context 'when logged in as a manager of a different position' do
      before { when_current_user_is other_manager }

      it { is_expected.to have_http_status(:forbidden) }
    end

    context 'when logged in as a manager of the position' do
      before { when_current_user_is manager }

      it { is_expected.to be_successful }
    end
  end
end
