# frozen_string_literal: true

require 'rails_helper'

describe 'toggling the active attribute of application templates' do
  let(:application) { create(:application_template) }
  let(:draft) { create(:application_draft, application_template: application) }
  before :each do
    when_current_user_is :staff
  end
  context 'on application template page' do
    before :each do
      visit application_path(application)
    end
    context 'application is inactive' do
      let(:application) { create(:application_template, active: false) }
      it 'has a button to activate the application' do
        click_button 'Activate application'
        expect(page).to have_button 'Deactivate application'
      end
      it 'puts a message in the flash' do
        expect_flash_message(:active_application)
        click_on 'Activate application'
      end
    end
    context 'application is active' do
      let(:application) { create(:application_template, active: true) }
      it 'has a button to deactivate the application' do
        click_button 'Deactivate application'
        expect(page).to have_button 'Activate application'
      end
      it 'puts a message in the flash' do
        expect_flash_message(:inactive_application)
        click_on 'Deactivate application'
      end
    end
  end
  context 'on editing application drafts page' do
    before :each do
      visit edit_draft_path(draft)
    end
    context 'application is inactive' do
      let(:application) { create(:application_template, active: false) }
      it 'has a button to activate the application' do
        click_button 'Activate application'
        expect(page).to have_button 'Deactivate application'
      end
      it 'puts a message in the flash' do
        expect_flash_message(:active_application)
        click_on 'Activate application'
      end
    end
    context 'application is active' do
      let(:application) { create(:application_template, active: true) }
      it 'has a button to deactivate the application' do
        click_button 'Deactivate application'
        expect(page).to have_button 'Activate application'
      end
      it 'puts a message in the flash' do
        expect_flash_message(:inactive_application)
        click_on 'Deactivate application'
      end
    end
  end
end
