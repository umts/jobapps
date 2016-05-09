require 'rails_helper'

describe SubscriptionsController do
  describe 'POST #create' do
    context 'user' do
      let(:submit) { post :create }
      it 'should deny the request' do
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:subscription) { create :subscription }
    let :submit do
      delete :destroy, id: subscription.id
    end
    context 'student' do
      it 'does not allow access' do
        when_current_user_is :student
        submit
        expect(response).to have_http_status :unauthorized
      end
    end
  end
end
