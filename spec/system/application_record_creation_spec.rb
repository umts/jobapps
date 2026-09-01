# frozen_string_literal: true

require 'rails_helper'

describe 'submitting application records' do
  let!(:application_template) { create(:application_template, :with_questions) }

  context 'when a student has been authenticated' do
    let(:student) { create(:user, :student) }

    before do
      when_current_user_is student
      visit application_path(application_template)
      application_template.position.update(not_hiring_text: 'custom text')
    end

    it 'creates an application submission for the current user' do
      expect { click_on 'Submit application' }.to change { student.application_submissions.count }.by(1)
    end

    it 'shows the first name from Active Directory as read-only' do
      expect(page).to have_field('First name', disabled: true, with: student.first_name)
    end

    it 'shows the last name from Active Directory as read-only' do
      expect(page).to have_field('Last name', disabled: true, with: student.last_name)
    end

    it 'updates the email when the applicant provides a different one' do
      fill_in 'Email', with: 'preferred@umass.edu'
      click_on 'Submit application'
      expect(student.reload.email).to eq 'preferred@umass.edu'
    end

    context 'when the application template has been marked as inactive' do
      before do
        application_template.update active: false
        visit current_path
      end

      it 'shows text explaining that the application is unavailable' do
        expect(page).to have_text(application_template.position.not_hiring_text)
      end
    end
  end
end
