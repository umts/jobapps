# frozen_string_literal: true

require 'rails_helper'

describe 'viewing eeo data page' do
  let!(:record_with_eeo_data) do
    create(:application_submission, ethnicity: 'White (Not of Hispanic origin)', gender: 'Male')
  end

  let!(:old_record_with_eeo_data) do
    create(:application_submission,
           created_at: 2.weeks.ago, ethnicity: 'Black (Not of Hispanic origin)', gender: 'Female')
  end

  before do
    when_current_user_is :staff
    visit staff_dashboard_path
    fill_in 'eeo_start_date', with: 1.week.ago
    fill_in 'eeo_end_date', with: 1.week.from_now
    click_button 'List EEO data'
  end

  it 'goes to the past applications page' do
    expect(page).to have_current_path(eeo_data_application_submissions_path, ignore_query: true)
  end

  it 'displays the ethnicity of valid applicant' do
    within('table.data_table') do
      expect(page).to have_text(record_with_eeo_data.ethnicity)
    end
  end

  it 'displays the gender of valid applicant' do
    within('table.data_table') do
      expect(page).to have_text(record_with_eeo_data.gender)
    end
  end

  it 'does not display ethnicity of applications outside the date range' do
    within('table.data_table') do
      expect(page).to have_no_text(old_record_with_eeo_data.ethnicity)
    end
  end

  it 'does not display the gender of outdated application' do
    within('table.data_table') do
      expect(page).to have_no_text(old_record_with_eeo_data.gender)
    end
  end

  it 'displays the formatted creation date of the application records' do
    time = record_with_eeo_data.created_at.to_fs :long_with_time
    expect(page).to have_text(time)
  end
end
