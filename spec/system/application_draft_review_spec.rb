# frozen_string_literal: true

require 'rails_helper'

describe 'previewing an application draft' do
  let(:template) { create(:application_template) }
  let(:draft) { create(:application_draft, application_template: template) }
  let!(:question) { create(:question, application_draft: draft) }

  before do
    when_current_user_is :staff
    visit draft_path(draft)
  end

  it 'has text explaining that this is a preview' do
    expect(page).to have_text('This is a preview of your changes')
  end

  it 'has a button to continue editing' do
    click_link('Continue editing')
    expect(page).to have_current_path(edit_draft_path(draft))
  end

  context 'when saving the application' do
    before { click_button('Save application') }

    it 'moves questions to the application template' do
      expect(template.reload.questions).to include(question)
    end

    it 'deletes the draft' do
      expect(template.drafts).to be_empty
    end
  end

  context 'when discarding the draft' do
    before { click_button('Discard changes') }

    it 'does not move questions to the application template' do
      expect(template.reload.questions).not_to include(question)
    end

    it 'deletes the draft' do
      expect(template.drafts).to be_empty
    end

    it 'redirects to the staff dashboard' do
      expect(page).to have_current_path(staff_dashboard_path)
    end
  end

  it 'has a disabled submit button' do
    expect(page).to have_button('Submit application', disabled: true)
  end
end
