# frozen_string_literal: true

require 'rails_helper'

describe 'saving and unsaving applications' do
  before do
    when_current_user_is :staff
  end

  context 'when saving an application record for later' do
    let!(:record) { create(:application_submission, reviewed: false) }

    before do
      visit staff_dashboard_path
      click_link record.user.proper_name, href: application_submission_path(record)
      page.fill_in 'application_submission_note_for_later', with: 'Put him in the brig'
      click_button 'Save'
    end

    it 'displays the number of saved applications in the link to their page' do
      name = record.position.name
      link = "View saved applications for #{name} (1)"
      expect(page).to have_link(link)
    end

    it 'has a link on the dashboard for saved applications' do
      click_link "View saved applications for #{record.position.name}"
      expect(page).to have_current_path(saved_applications_position_path(record.position))
    end

    it 'moves the application record to the saved applications page' do
      click_link "View saved applications for #{record.position.name}"
      expect(page).to have_link record.user.proper_name, href: application_submission_path(record)
    end

    it 'redirects to the dashboard' do
      expect(page).to have_current_path(staff_dashboard_path)
    end

    it 'moves the application record off the dashboard' do
      expect(page).to have_no_link record.user.proper_name, href: application_submission_path(record)
    end

    it 'puts a notice in the flash' do
      expect(page).to have_text('Application successfully updated')
    end
  end

  context 'when moving the application record back to the dashboard' do
    let(:record) do
      create(:application_submission, reviewed: false, saved_for_later: true, note_for_later: 'this is required')
    end

    before do
      visit application_submission_path(record)
      click_button 'Move back to dashboard'
    end

    it 'moves the record back to the dashboard' do
      expect(page).to have_link(record.user.proper_name)
    end

    it 'redirects to the dashboard' do
      expect(page).to have_current_path(staff_dashboard_path)
    end

    it 'indicates there are no saved applications on the dashboard' do
      expect(page).to have_text('No saved applications')
    end

    it 'puts a notice in the flash' do
      expect(page).to have_text('Application successfully updated')
    end
  end

  context 'when adding a note and date for later' do
    let(:record) { create(:application_submission, reviewed: false) }

    before do
      visit application_submission_path(record)
      page.fill_in 'application_submission_note_for_later', with: 'Taken to sick bay'
      page.fill_in 'application_submission_date_for_later', with: Time.zone.today.to_fs(:db)
      click_button 'Save'
      record.reload
    end

    it 'updates the note for later' do
      expect(record.note_for_later).to eq('Taken to sick bay')
    end

    it 'updates the date for later' do
      expect(record.date_for_later).to eq(Time.zone.today)
    end

    it 'sets saved for later to true' do
      expect(record.saved_for_later).to be(true)
    end
  end

  context 'with an application_submission that has been saved for later' do
    let(:saved_date) { saved_record.date_for_later.to_fs(:long) }
    let :saved_record do
      create(:application_submission, reviewed: false, note_for_later: 'This is my note',
                                      date_for_later: Time.zone.today, saved_for_later: true)
    end

    it 'displays the date on the saved_for_later page' do
      visit saved_applications_position_path(saved_record.position)
      expect(page).to have_text(saved_date)
    end

    it 'displays the date on the application record page' do
      visit application_submission_path(saved_record)
      expect(page).to have_text(saved_date)
    end

    it 'displays the note on the saved_for_later page' do
      visit saved_applications_position_path(saved_record.position)
      expect(page).to have_text('This is my note')
    end

    it 'displays the note on the application record page' do
      visit application_submission_path(saved_record)
      expect(page).to have_text('This is my note')
    end
  end
end
