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
end
