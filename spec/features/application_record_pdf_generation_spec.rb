require 'rails_helper'

describe 'generating a pdf to print an application record' do
  let(:record) { create :application_record, :with_unavailability}
  before :each do
    when_current_user_is :staff, integration: true
    visit application_record_path(record)
  end
  it 'generates a pdf of the application record for printing' do
    click_button 'Print this page'
    expect(page.current_url).to eql application_record_url(record, format: :pdf)
  end
end
