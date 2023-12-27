# frozen_string_literal: true

require 'rails_helper'

describe 'generating a pdf to print an application record' do
  let(:unavail) { create(:unavailability, sunday: ['7AM']) }
  let(:record) { create(:application_submission, unavailability: unavail) }
  before :each do
    when_current_user_is :staff
    visit application_submission_path(record)
  end
  it 'generates a pdf of the application record for printing' do
    click_button 'Print this page'
    path = application_submission_path(record, format: :pdf)
    expect(page.current_path).to eql path
  end
end
