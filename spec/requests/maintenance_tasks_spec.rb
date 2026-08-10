# frozen_string_literal: true

require 'rails_helper'

describe 'MaintenanceTasks engine' do
  describe 'GET /maintenance_tasks' do
    context 'when the current user is staff' do
      before do
        when_current_user_is :staff
      end

      it 'denies access' do
        get '/maintenance_tasks'
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'when the current user is an admin' do
      before do
        when_current_user_is :admin
      end

      it 'allows access' do
        get '/maintenance_tasks'
        expect(response).to have_http_status :ok
      end
    end
  end
end
