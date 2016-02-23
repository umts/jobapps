require 'rails_helper'

describe 'creating new drafts' do
  let!(:application) { create :application_template }
  before :each do
    when_current_user_is :staff, integration: true
    visit staff_dashboard_url
  end
  context 'clicking save changes and continue editing' do
    it 'creates a new draft' do
      expect(ApplicationDraft.count).to eql 0
      expect { click_link 'Edit application' }
        .to change { ApplicationDraft.count }.by 1
    end
  end
end
