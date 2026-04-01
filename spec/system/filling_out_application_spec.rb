# frozen_string_literal: true

require 'rails_helper'

describe 'filling out an application' do
  let(:application) do
    create(:application_template, :with_questions)
  end

  before do
    when_current_user_is :student
    visit application_path(application)
  end

  it 'redirects to the student dashboard' do
    click_on 'Submit application'
    expect(page).to have_current_path(student_dashboard_path)
  end

  it 'renders the application receipt flash message' do
    click_on 'Submit application'
    expect(page).to have_text('Your application has been submitted. Thank you!')
  end
end
