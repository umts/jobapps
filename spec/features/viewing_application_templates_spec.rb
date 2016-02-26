require 'rails_helper'

describe 'viewing application forms on dashboard' do
  let!(:position) { create :position }
  let!(:user) { create :user, staff: true }
  let!(:app_with_draft) { create :application_template }
  let!(:app_without_draft) { create :application_template }
  let!(:draft) do
    create :application_draft,
           application_template: app_with_draft,
           user: user
  end
  before :each do
    when_current_user_is user, integration: true
    visit staff_dashboard_url
  end
  it 'has links to view the applications' do
    click_link 'View application',
               href: application_path(app_with_draft)
    expect(page.current_url)
      .to include application_path(app_with_draft)
    visit staff_dashboard_url
    click_link 'View application',
               href: application_path(app_without_draft)
    expect(page.current_url)
      .to include application_path(app_without_draft)
  end
  it 'has a link to edit any drafts owned by the current user' do
    click_link 'Resume editing saved draft',
               href: edit_draft_path(draft)
    expect(page.current_url)
      .to include edit_draft_path(draft)
  end
  it 'has links to edit the applications when a draft does not yet exist' do
    action_path = new_draft_path(application_template_id: app_without_draft.id)
    click_link 'Edit application',
               href: action_path
    expect(page.current_url)
      .to include edit_draft_path(ApplicationDraft.all.last.id)
  end
  it 'has a link to create an application if one does not exist' do
    click_link 'Create application',
               href: new_application_path(position_id: position.id)
    expect(page.current_url)
      .to include edit_draft_path(ApplicationDraft.all.last.id)
  end
  it 'has a button to discard drafts' do
    expect { click_button 'Discard saved draft' }
      .to change { ApplicationDraft.count }.by(-1)
  end
end
