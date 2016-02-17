require 'rails_helper'

describe 'exportig a csv' do
  let(:start_date){ 1.week.ago.strftime('%m/%d/%Y') }
  let(:end_date){ 1.week.since.strftime('%m/%d/%Y') }
  let!(:record_with_completed_interview) { create :application_record }
  before :each do
    visit staff_dashboard_url
    fill_in 'records_start_date', with: start_date
    fill_in 'records_end_date', with: end_date #button
    click_button 'List Applications' #button for csv export
  end
end
