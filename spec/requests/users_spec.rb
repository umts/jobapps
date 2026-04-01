# frozen_string_literal: true

require 'rails_helper'

describe 'UsersController' do
  describe 'DELETE /users/:id' do
    subject(:submit) do
      delete "/users/#{user.id}"
      response
    end

    let(:user) { create(:user) }

    context 'with staff privilege' do
      before { when_current_user_is :staff }

      it { is_expected.to have_http_status(:unauthorized) }
    end
  end
end
