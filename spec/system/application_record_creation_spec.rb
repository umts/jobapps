# frozen_string_literal: true

require 'rails_helper'

describe 'submitting application records' do
  let!(:application_template) { create(:application_template, :with_questions) }

  context 'when a student has been authenticated and has a user object' do
    let(:student) { create(:user, :student) }

    before do
      when_current_user_is student
      visit application_path(application_template)
      application_template.position.update(not_hiring_text: 'custom text')
    end

    it 'automatically fills in the user first name' do
      expect(page).to have_field('First name', with: student.first_name)
    end

    it 'automatically fills in the user last name' do
      expect(page).to have_field('Last name', with: student.last_name)
    end

    it 'automatically fills in the user email' do
      expect(page).to have_field('Email', with: student.email)
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

  context 'when a student has been authenticated but has no user object' do
    let(:spire) { '12345678@umass.edu' }
    let(:user_attributes) { { first_name: 'John', last_name: 'Smith', email: 'johnsmith@umass.edu', spire: } }

    before do
      when_current_user_is nil
      page.set_rack_session(spire:)
      visit application_path(application_template)
      application_template.position.update(not_hiring_text: 'custom text')
    end

    it 'creates a new user' do
      fill_in_fields_for User, attributes: user_attributes.except(:spire)
      expect { click_on 'Submit application' }.to change(User, :count).by(1)
    end

    it 'creates a user object with the user-provided information' do
      fill_in_fields_for User, attributes: user_attributes.except(:spire)
      click_on 'Submit application'
      expect(User.last).to have_attributes user_attributes
    end

    context 'when the application template has been marked as inactive' do
      before do
        application_template.update active: false
        visit current_path
      end

      it 'shows text explaining that the application is unavailable' do
        expect(page).to have_text application_template.position.not_hiring_text
      end
    end
  end
end
