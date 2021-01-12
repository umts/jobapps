# frozen_string_literal: true

require 'rails_helper'

describe 'creating new drafts' do
  let!(:application) { create :application_template }
  before :each do
    when_current_user_is :staff, system: true
    visit staff_dashboard_path
  end
  it 'creates a new draft' do
    expect(ApplicationDraft.count).to be 0
    expect { click_link 'Edit application' }
      .to change { ApplicationDraft.count }.by 1
  end
end
