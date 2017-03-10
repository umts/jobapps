require 'rails_helper'

describe 'saving or unsaving applications' do
  before :each do
    when_current_user_is :staff, integration: true
  end
  context 'saving an application record for later' do
    let!(:record) { create :application_submission, reviewed: false }
    before :each do
      visit staff_dashboard_url
      click_link record.user.proper_name,
                 href: application_submission_path(record)
      page.fill_in 'note_for_later', with: 'This is required'
      click_button 'Save for later'
    end
    it 'moves the application record to the saved applications page' do
      click_link "View saved applications for #{record.position.name}"
      expect(page.current_url)
        .to eql saved_applications_position_url(record.position)
      expect(page).to have_link record.user.proper_name,
                                href: application_submission_path(record)
    end
    it 'redirects to the dashboard' do
      expect(page.current_url).to eql staff_dashboard_url
    end
    it 'moves the application record off the dashboard' do
      expect(page).not_to have_link record.user.proper_name,
                                    href: application_submission_path(record)
    end
    it 'puts a notice in the flash' do
      expect(page).to have_text 'Application saved for later.'
    end
  end
  context 'moving the application record back to the dashboard' do
    let!(:record) do
      create :application_submission,
             reviewed: false,
             saved_for_later: true,
             note_for_later: 'this is required'
    end
    before :each do
      visit application_submission_url(record)
    end
    it 'moves the record back to the dashboard' do
      click_button 'Move back to dashboard'
      expect(page).to have_link record.user.proper_name
    end
    it 'redirects to the dashboard' do
      click_button 'Move back to dashboard'
      expect(page.current_url).to eql staff_dashboard_url
    end
    it 'puts a notice in the flash' do
      click_button 'Move back to dashboard'
      expect(page).to have_text 'Application moved back to dashboard'
    end
  end
  context 'adding a note and date for later' do
    let!(:record) { create :application_submission, reviewed: false }
    it 'saves all the relevant attributes' do
      visit application_submission_url(record)
      page.fill_in 'note_for_later', with: 'This is my note'
      page.fill_in 'date_for_later', with: Time.zone.today.strftime('%m/%d/%Y')
      click_button 'Save for later'
      record.reload
      expect(record.note_for_later).to eql 'This is my note'
      expect(record.date_for_later).to eql Time.zone.today
      expect(record.saved_for_later).to be true
    end
    context 'application_submission has been saved for later' do
      let :saved_record do
        create :application_submission,
               reviewed: false,
               note_for_later: 'This is my note',
               date_for_later: Time.zone.today,
               saved_for_later: true
      end
      it 'displays the date on the saved_for_later page' do
        visit saved_applications_position_url(saved_record.position)
        expect(page).to have_text format_date saved_record.date_for_later
      end
      it 'displays the date on the application record page' do
        visit saved_applications_position_url(saved_record.position)
        expect(page).to have_text format_date saved_record.date_for_later
      end
      it 'displays the note on the saved_for_later page' do
        visit saved_applications_position_url(saved_record.position)
        expect(page).to have_text 'This is my note'
      end
      it 'displays the note on the application record page' do
        visit application_submission_url(saved_record)
        expect(page).to have_text 'This is my note'
      end
    end
  end
end
