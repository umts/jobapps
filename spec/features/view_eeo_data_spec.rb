# frozen_string_literal: true

require 'rails_helper'

describe 'viewing eeo data page' do
  # datepicker requires m/d/Y format
  let(:start_date) { 1.week.ago.strftime('%m/%d/%Y') }
  let(:end_date) { 1.week.since.strftime('%m/%d/%Y') }
  let!(:record_with_eeo_data) do
    create :application_submission,
           ethnicity: 'White (Not of Hispanic origin)',
           gender: 'Male'
  end
  let!(:old_record_with_eeo_data) do
    create :application_submission,
           created_at: 2.weeks.ago,
           ethnicity: 'Black (Not of Hispanic origin)',
           gender: 'Female'
  end
  before :each do
    when_current_user_is :staff
    visit staff_dashboard_url
    fill_in 'eeo_start_date', with: start_date
    fill_in 'eeo_end_date', with: end_date
    click_button 'List EEO data'
  end

  it 'goes to the past applications page' do
    expect(page.current_url)
      .to include eeo_data_application_submissions_url
  end

  it 'displays the ethnicity of valid applicant' do
    within('table.data_table') do
      expect(page)
        .to have_text record_with_eeo_data.ethnicity
    end
  end
  it 'displays the gender of valid applicant' do
    within('table.data_table') do
      expect(page)
        .to have_text record_with_eeo_data.gender
    end
  end

  it 'does not display ethnicity of outdated application' do
    within('table.data_table') do
      expect(page)
        .not_to have_text old_record_with_eeo_data.ethnicity
    end
  end
  it 'does not display the gender of outdated application' do
    within('table.data_table') do
      expect(page)
        .not_to have_text old_record_with_eeo_data.gender
    end
  end

  it 'displays the formatted creation date of the application records' do
    time = record_with_eeo_data.created_at.to_formatted_s :long_with_time
    expect(page).to have_text time
  end
end
