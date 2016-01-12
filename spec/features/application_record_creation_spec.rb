require 'rails_helper'

describe 'submitting application records' do
  # we need to create a question in this application template,
  # otherwise there is nothing to fill out and so the student will be
  # told to go away
  let!(:application_template) { create :application_template, :with_questions }
  context 'student has been authenticated and has a user object' do
    let(:student) do
      create :user, :student,
             first_name: 'John',
             last_name: 'Smith',
             email: 'johnsmith@umass.edu'
    end
    before :each do
      when_current_user_is student, integration: true
      visit application_template_path(application_template)
    end
    it 'automatically fills in the user fields' do
      expect(find_field('First name').value).to eql student.first_name
      expect(find_field('Last name').value).to eql student.last_name
      expect(find_field('Email').value).to eql student.email
    end
  end
  context 'student has been authenticated but has no user object' do
    before :each do
      when_current_user_is nil, integration: true
      page.set_rack_session spire: '12345678@umass.edu'
      visit application_template_path(application_template)
    end
    it 'creates a user object based on how the user fields are filled in' do
      user_attributes = { first_name: 'John',
                          last_name: 'Smith',
                          email: 'johnsmith@umass.edu' }
      fill_in_fields_for User, attributes: user_attributes
      expect { click_on 'Submit application' }
        .to change { User.count }.by 1
      expect(User.last).to have_attributes user_attributes
    end
  end
end
