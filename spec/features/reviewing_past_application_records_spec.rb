require 'rails_helper'

describe 'viewing past applications' do
  let(:start_date){ 1.week.ago.strftime('%m/%d/%Y') }
  let(:end_date){ 1.week.since.strftime('%m/%d/%Y') }
  Timecop.freeze Time.zone.today do
    let!(:record) { create :application_record }
    let!(:record_with_completed_interview) { create :application_record }
    let!(:interview) { create :interview, application_record: record }
    let!(:completed_interview) { create :interview,
      application_record: record_with_completed_interview,
      completed: true }
    let!(:record_without_interview) { create :application_record }
  end
  before :each do
    when_current_user_is :staff, integration: true
    visit staff_dashboard_url
    fill_in 'records_start_date', with: start_date
    fill_in 'records_end_date', with: end_date
    click_button 'List Applications'
  end
  it 'goes to the past applications page' do
    expect(page.current_url).to include past_applications_application_records_url
  end
  it 'lists the proper name of applicants' do
    assert_text "#{record.user.last_name}, #{record.user.first_name}"
  end
  it 'displays the formatted creation date of the application records' do
    assert_text record.created_at.strftime '%A, %B %e, %Y - %l:%M %P'
  end
  it 'displays a table of application records' do
    page.has_table?('data_table')
  end
  it 'displays the staff note of the applications' do
    assert_text record.staff_note
  end
  it 'provides a UNIX timestamp by which to sort the records' do
    has_css? 'data-order' => record.created_at.to_i
  end
  it 'displays the date any interviews are scheduled' do
    assert_text record.interview.scheduled.strftime '%A, %B %e, %Y - %l:%M %P'
  end
  it 'displays the date any interviews were completed' do
    assert_text "Completed #{record_with_completed_interview
    .interview.scheduled.strftime '%A, %B %e, %Y - %l:%M %P'}"
  end
  it 'displays text that the interview has not been scheduled' do
    assert_text 'not scheduled'
  end
  it 'displays any interview notes' do
    assert_text record.interview.interview_note
  end
end
