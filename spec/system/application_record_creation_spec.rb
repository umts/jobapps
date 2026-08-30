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
