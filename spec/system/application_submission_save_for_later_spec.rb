# frozen_string_literal: true

require 'rails_helper'

describe 'saving or unsaving applications' do
  before do
    when_current_user_is :staff
  end

  context 'saving an application record for later' do
    let!(:record) { create(:application_submission, reviewed: false) }

    before do
      visit staff_dashboard_path
      click_link record.user.proper_name,
                 href: application_submission_path(record)
      page.fill_in 'application_submission_note_for_later',
                   with: 'Put him in the brig'
      click_button 'Save'
    end

    it 'displays the number of saved applications in the link to their page' do
      name = record.position.name
      link = "View saved applications for #{name} (1)"
      expect(page).to have_link link
    end

    it 'moves the application record to the saved applications page' do
      click_link "View saved applications for #{record.position.name}"
      expect(page.current_path)
        .to eql saved_applications_position_path(record.position)
      expect(page).to have_link record.user.proper_name,
                                href: application_submission_path(record)
    end

    it 'redirects to the dashboard' do
      expect(page.current_path).to eql staff_dashboard_path
    end

    it 'moves the application record off the dashboard' do
      expect(page).to have_no_link record.user.proper_name,
                                   href: application_submission_path(record)
    end

    it 'puts a notice in the flash' do
      expect(page).to have_text 'Application successfully updated'
    end
  end

  context 'moving the application record back to the dashboard' do
    let!(:record) do
      create(:application_submission,
             reviewed: false,
             saved_for_later: true,
             note_for_later: 'this is required')
    end

    before do
      visit application_submission_path(record)
    end

    it 'moves the record back to the dashboard' do
      click_button 'Move back to dashboard'
      expect(page).to have_link record.user.proper_name
    end

    it 'redirects to the dashboard' do
      click_button 'Move back to dashboard'
      expect(page.current_path).to eql staff_dashboard_path
    end

    it 'indicates there are no saved applications on the dashboard' do
      click_button 'Move back to dashboard'
      expect(page).to have_text 'No saved applications'
    end

    it 'puts a notice in the flash' do
      click_button 'Move back to dashboard'
      expect(page).to have_text 'Application successfully updated'
    end
  end

  context 'adding a note and date for later' do
    let!(:record) { create(:application_submission, reviewed: false) }
    let(:saved_date) { saved_record.date_for_later.to_fs(:long) }

    it 'saves all the relevant attributes' do
      visit application_submission_path(record)
      page.fill_in 'application_submission_note_for_later',
                   with: 'Taken to sick bay'
      page.fill_in 'application_submission_date_for_later',
                   with: Time.zone.today.to_fs(:db)
      click_button 'Save'
      record.reload
      expect(record.note_for_later).to eql 'Taken to sick bay'
      expect(record.date_for_later).to eql Time.zone.today
      expect(record.saved_for_later).to be true
    end

    context 'application_submission has been saved for later' do
      let :saved_record do
        create(:application_submission,
               reviewed: false,
               note_for_later: 'This is my note',
               date_for_later: Time.zone.today,
               saved_for_later: true)
      end

      it 'displays the date on the saved_for_later page' do
        visit saved_applications_position_path(saved_record.position)
        expect(page).to have_text saved_date
      end

      it 'displays the date on the application record page' do
        visit saved_applications_position_path(saved_record.position)
        expect(page).to have_text saved_date
      end

      it 'displays the note on the saved_for_later page' do
        visit saved_applications_position_path(saved_record.position)
        expect(page).to have_text 'This is my note'
      end

      it 'displays the note on the application record page' do
        visit application_submission_path(saved_record)
        expect(page).to have_text 'This is my note'
      end
    end
  end
end
