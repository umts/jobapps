# frozen_string_literal: true

require 'rails_helper'

describe 'reviewing application templates' do
  let(:application) { create(:application_template, :with_questions) }
  let(:user) { create(:user, :staff) }

  before do
    when_current_user_is user
    visit application_path(application)
  end

  it 'displays the title of the application' do
    expect(page).to have_css 'h1', text: application.position.name
  end

  context 'the application is active' do
    let(:application) { create(:application_template, active: true) }

    it 'tells the user that the application is active' do
      expect(page).to have_text 'application is available'
    end
  end

  context 'the application is inactive' do
    let(:application) { create(:application_template, active: false) }

    it 'tells the user that the application is inactive' do
      expect(page).to have_text 'application is currently not available'
    end

    it 'still displays the application' do
      application.questions.each do |q|
        expect(page).to have_text q.prompt
      end
    end
  end

  it 'does not contain a submit button for the form' do
    expect(page).not_to have_button('Submit application')
  end

  it 'pre-fills the personal information values' do
    expect(find_field('First name').value).to eql user.first_name
    expect(find_field('Last name').value).to eql user.last_name
    expect(find_field('Email').value).to eql user.email
  end

  it 'uses the slug attribute of the application template as the path slug' do
    expect(page.current_path).to include application.slug
  end

  it 'shows any questions the application has' do
    expect(page).to have_text application.questions.first.prompt
  end
end
