# frozen_string_literal: true

require 'rails_helper'

describe 'Subscriptions' do
  describe 'POST /subscriptions' do
    subject(:submit) { post '/subscriptions', params: { subscription: attributes } }

    let(:position) { create(:position) }
    let(:subscriber) { create(:user) }

    let(:valid_attributes) do
      attributes_for(:subscription).merge(
        position_id: position.id,
        user_id: subscriber.id
      )
    end

    let(:attributes) { valid_attributes }

    shared_examples 'an authorized subscription manager' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        context 'with valid attributes' do
          it 'creates a subscription' do
            expect { submit }.to change(Subscription, :count).by(1)
          end

          it 'creates a subscription with the given attributes' do
            submit
            subscription = Subscription.find_by!(email: attributes[:email])
            expect(subscription).to have_attributes(attributes)
          end

          it 'redirects to the position edit page' do
            submit
            expect(response).to redirect_to(edit_position_path(position))
          end
        end

        context 'with invalid attributes' do
          let(:attributes) { valid_attributes.merge(email: nil) }

          it 'does not create a subscription' do
            expect { submit }.not_to change(Subscription, :count)
          end

          it 'redirects to the position edit page' do
            submit
            expect(response).to redirect_to(edit_position_path(position))
          end
        end
      end
    end

    it_behaves_like 'an authorized subscription manager', :staff
    it_behaves_like 'an authorized subscription manager', :admin

    context 'with student privilege' do
      before { when_current_user_is :student }

      it 'returns forbidden' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /subscriptions/:id' do
    subject(:submit) { delete "/subscriptions/#{subscription.id}" }

    let(:subscription) { create(:subscription) }

    shared_examples 'an authorized subscription manager' do |role|
      context "with #{role} privilege" do
        before { when_current_user_is role }

        it 'destroys the subscription' do
          subscription
          expect { submit }.to change(Subscription, :count).by(-1)
        end

        it 'redirects to the position edit page' do
          position = subscription.position
          submit
          expect(response).to redirect_to(edit_position_path(position))
        end
      end
    end

    it_behaves_like 'an authorized subscription manager', :staff
    it_behaves_like 'an authorized subscription manager', :admin

    context 'with student privilege' do
      before { when_current_user_is :student }

      it 'returns forbidden' do
        submit
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
