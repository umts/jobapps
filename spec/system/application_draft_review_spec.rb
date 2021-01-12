# frozen_string_literal: true

require 'rails_helper'

describe 'previewing an application draft' do
  let!(:template) { create :application_template }
  let!(:draft) { create :application_draft, application_template: template }
  let!(:question) { create :question, application_draft: draft }
  context 'on draft preview page' do
    before :each do
      when_current_user_is :staff, system: true
      visit draft_path(draft)
    end
    it 'has text explaining that this is a preview' do
      assert_text('This is a preview of your changes')
    end
    it 'has a button to continue editing' do
      click_link('Continue editing')
      expect(page.current_path).to eql edit_draft_path(draft)
    end
    it 'has a button to save the application' do
      click_button('Save application')
      expect(template.reload.questions).to include question
      expect(template.drafts).to be_empty
    end
    it 'has a button to discard changes' do
      expect(template.drafts.first).to eql draft
      click_button('Discard changes')
      template.reload
      expect(template.drafts).to be_empty
      expect(page.current_path).to eql staff_dashboard_path
    end
    it 'has a disabled submit button' do
      expect(page).to have_button('Submit application', disabled: true)
    end
  end
end
