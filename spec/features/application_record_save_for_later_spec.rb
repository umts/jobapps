require 'rails_helper'

describe 'saving or unsaving applications' do
  before :each do
    when_current_user_is :staff, integration: true
  end
  context 'saving an application record for later' do
    let!(:record) { create :application_record, reviewed: false }
    before :each do
      visit staff_dashboard_url
      click_link record.user.proper_name, href: application_record_path(record)
      click_button 'Save for later'
    end
    it 'moves the application record to the saved applications page' do
      click_link "View saved applications for #{record.position.name}"
      expect(page.current_url)
        .to eq saved_applications_position_url(record.position)
      expect(page).to have_link record.user.proper_name,
        href: application_record_path(record)
    end
    it 'redirects to the dashboard' do
      expect(page.current_url).to eq staff_dashboard_url
    end
    it 'moves the application record off the dashboard' do
      expect(page).not_to have_link record.user.proper_name,
        href: application_record_path(record)
    end
    it 'puts a notice in the flash' do
      expect(page).to have_text 'Application saved for later.'
    end
  end
  context 'moving the application record back to the dashboard' do
    let!(:record) do
      create :application_record,
        reviewed: false,
        saved_for_later: true
    end
    before :each do
      visit application_record_url(record)
    end
    it 'moves the record back to the dashboard' do
      click_button 'Move back to dashboard'
      expect(page).to have_link record.user.proper_name
    end
    it 'redirects to the dashboard' do
      click_button 'Move back to dashboard'
      expect(page.current_url).to eq staff_dashboard_url
    end
    it 'puts a notice in the flash' do
      click_button 'Move back to dashboard'
      expect(page).to have_text 'Application moved back to dashboard'
    end
  end
  context 'setting a date for moving the record back to dashboard' do
    it 'moves the record back to the dashboard when the date is reached'
    it 'displays the date on the saved_for_later page'
  end
  context 'adding a note for later' do
    let!(:record) { create :application_record, reviewed: false }
    it 'displays the note on the saved_for_later page' do
      visit application_record_url(record)
      alick_button 'Save for later'
      visit saved_applications_position_url(record.position)
      expect(page).to have_text 'This is my note'
    end
    it 'displays the note on the application record page' do
      visit application_record_url(record)
      page.fill_in 'note_for_later', with: 'This is my note'
      click_button 'Save for later'
      visit application_record_url(record)
      expect(page).to have_text 'This is my note'
    end
  end
end
