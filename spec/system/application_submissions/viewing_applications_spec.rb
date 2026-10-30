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

  context 'when viewing a submitted application' do
    let(:submission) do
      create(:application_submission,
             data: [['When can you start?', '2027-01-01', 'date', 1], ['What is your name?', 'John Doe', 'text', 2]])
    end

    before do
      when_current_user_is :staff
      visit application_submission_path(submission)
    end

    it 'shows formatted date' do
      expect(page).to have_text('01/01/2027')
    end

    it 'shows other response as entered' do
      expect(page).to have_text('John Doe')
    end
  end
end
