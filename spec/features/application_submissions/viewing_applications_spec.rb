# frozen_string_literal: true

require 'rails_helper'

describe 'viewing job applications individually' do
  context 'there are no pending applications or interviews' do
    let!(:position) { create :position }
    # There must be a position for which there exist
    # neither applications nor interviews.
    before :each do
      when_current_user_is :staff
      visit staff_dashboard_url
    end
    it 'lets the user know there are no pending applications' do
      expect(page).to have_text 'No pending applications'
    end
    it 'lets the user know there are no pending interviews' do
      expect(page).to have_text 'No pending interviews'
    end
  end
end
