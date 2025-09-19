# frozen_string_literal: true

require 'rails_helper'

describe 'viewing job applications individually' do
  context 'when there are no pending applications or interviews' do
    before do
      create(:position)
      when_current_user_is :staff
      visit staff_dashboard_path
    end

    it 'lets the user know there are no pending applications' do
      expect(page).to have_text('No pending applications')
    end

    it 'lets the user know there are no pending interviews' do
      expect(page).to have_text('No pending interviews')
    end
  end
end
