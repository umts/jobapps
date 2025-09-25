# frozen_string_literal: true

require 'rails_helper'

describe 'viewing application forms on the staff dashboard' do
  let!(:position) { create(:position) }
  let!(:user) { create(:user, staff: true) }
  let!(:app_with_draft) { create(:application_template) }
  let!(:app_without_draft) { create(:application_template) }
  let!(:draft) do
    create(:application_draft, application_template: app_with_draft, user:)
  end

  before do
    when_current_user_is user
    visit staff_dashboard_path
  end

  it 'has links to view applications with drafts' do
    expect(page).to have_link('View application', href: application_path(app_with_draft))
  end

  it 'has links to view the applications' do
    expect(page).to have_link('View application', href: application_path(app_without_draft))
  end

  it 'has a link to edit any drafts owned by the current user' do
    expect(page).to have_link('Resume editing saved draft', href: edit_draft_path(draft))
  end

  it 'has links to edit the applications when a draft does not yet exist' do
    expect(page).to have_link('Edit application', href: new_draft_path(application_template_id: app_without_draft.id))
  end

  it 'has a link to create an application if one does not exist' do
    expect(page).to have_link('Create application', href: new_application_path(position_id: position.id))
  end

  it 'has a button to discard drafts' do
    expect { click_button 'Discard saved draft' }.to change(ApplicationDraft, :count).by(-1)
  end
end
