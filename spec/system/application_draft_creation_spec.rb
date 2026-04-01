# frozen_string_literal: true

require 'rails_helper'

describe 'creating new drafts' do
  before do
    create(:application_template)
    when_current_user_is :staff
    visit staff_dashboard_path
  end

  it 'creates a new draft' do
    expect { click_link 'Edit application' }.to change(ApplicationDraft, :count).by(1)
  end
end
