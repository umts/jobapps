# frozen_string_literal: true

require 'rails_helper'

describe 'UsersController' do
  describe 'DELETE /users/:id' do
    subject(:submit) do
      delete "/users/#{user.id}"
      response
    end

    let(:user) { create(:user) }

    context 'when the current user is a manager' do
      before { when_current_user_is :manager }

      it { is_expected.to have_http_status(:forbidden) }
    end
  end
end
