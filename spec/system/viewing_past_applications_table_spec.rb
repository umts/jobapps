# frozen_string_literal: true

require 'rails_helper'

describe 'viewing table of past applications' do
  let(:record) do
    create(:application_submission, rejection_message: "it's not you, it's me", staff_note: 'they smelled terrible')
  end
  let(:record_with_completed_interview) { create(:application_submission) }

  before do
    create(:application_submission) # No interview scheduled
    create(:interview, application_submission: record, interview_note: 'bunnies')
    create(:interview, application_submission: record_with_completed_interview, completed: true)

    when_current_user_is :staff
    visit staff_dashboard_path
    fill_in 'records_start_date', with: 1.week.ago
    fill_in 'records_end_date', with: 1.week.from_now
    click_button 'List Applications'
  end

  it 'goes to the past applications page' do
    expect(page).to have_current_path(past_applications_application_submissions_path, ignore_query: true)
  end

  it 'lists the proper name of applicants' do
    expect(page).to have_text("#{record.user.last_name}, #{record.user.first_name}")
  end

  it 'displays the formatted creation date of the application records' do
    expect(page).to have_text(record.created_at.to_fs(:long_with_time))
  end

  it 'displays the staff note of the applications' do
    expect(page).to have_text(record.staff_note)
  end

  it 'displays the rejection message of the application' do
    expect(page).to have_text(record.rejection_message)
  end

  it 'provides a UNIX timestamp by which to sort the records' do
    expect(page).to have_css("*[data-order=#{record.created_at.to_i}]")
  end

  it 'displays the date any interviews are scheduled' do
    expect(page).to have_text(record.interview.scheduled.to_fs(:long_with_time))
  end

  it 'displays the date any interviews were completed' do
    time = record_with_completed_interview.interview.scheduled.to_fs(:long_with_time)
    expect(page).to have_text "Completed #{time}"
  end

  it 'displays text that the interview has not been scheduled' do
    expect(page).to have_text('not scheduled')
  end

  it 'displays any interview notes' do
    expect(page).to have_text(record.interview.interview_note)
  end
end
