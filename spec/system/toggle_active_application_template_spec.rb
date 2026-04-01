# frozen_string_literal: true

require 'rails_helper'

describe 'toggling the active attribute of application templates' do
  before do
    when_current_user_is :staff
  end

  context 'when viewing the application template' do
    before do
      visit application_path(application)
    end

    context 'when the application is inactive' do
      let(:application) { create(:application_template, active: false) }

      it 'has a button to activate the application' do
        click_button 'Activate application'
        expect(page).to have_button('Deactivate application')
      end

      it 'puts a message in the flash' do
        click_on 'Activate application'
        expect(page).to have_text('The application is now active.')
      end
    end

    context 'when the application is active' do
      let(:application) { create(:application_template, active: true) }

      it 'has a button to deactivate the application' do
        click_button 'Deactivate application'
        expect(page).to have_button('Activate application')
      end

      it 'puts a message in the flash' do
        click_on 'Deactivate application'
        expect(page).to have_text('The application is now inactive.')
      end
    end
  end

  context 'when editing the application draft' do
    let(:draft) { create(:application_draft, application_template: application) }

    before do
      visit edit_draft_path(draft)
    end

    context 'when the application is inactive' do
      let(:application) { create(:application_template, active: false) }

      it 'has a button to activate the application' do
        click_button 'Activate application'
        expect(page).to have_button('Deactivate application')
      end

      it 'puts a message in the flash' do
        click_on 'Activate application'
        expect(page).to have_text('The application is now active.')
      end
    end

    context 'when the application is active' do
      let(:application) { create(:application_template, active: true) }

      it 'has a button to deactivate the application' do
        click_button 'Deactivate application'
        expect(page).to have_button('Activate application')
      end

      it 'puts a message in the flash' do
        click_on 'Deactivate application'
        expect(page).to have_text('The application is now inactive.')
      end
    end
  end
end
