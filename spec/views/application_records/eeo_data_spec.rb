require 'rails_helper'
include RSpecHtmlMatchers

describe 'application_records/eeo_data.haml' do
  before :each do
    ethnicity_counts = {}
    gender_counts = {}
    combined_counts = {}
    @ethnicity = 'The ethnicity of Rick'
    @gender = 'The gender of Rick'
    @user1 = create :user, first_name: 'Rick', last_name: 'Cat'
    @record1 = create :application_record,
                      user: @user1,
                      ethnicity: @ethnicity,
                      gender: @gender
    records = [@record1]
    # all these assignings because error otherwise
    assign :records, records
    assign :ethnicity_counts, ethnicity_counts
    assign :gender_counts, gender_counts
    assign :combined_counts, combined_counts
  end
  it 'displays a table of application records' do
    render
    expect(rendered).to have_tag 'table', with: { class: 'data_table' }
  end
  it 'displays the formatted creation date of the application records' do
    render
    expect(rendered).to include format_date_time @record1.created_at
  end
  it 'displays the ethnicity of the relevant applicants' do
    render
    expect(rendered).to include "#{@ethnicity}"
  end
  it 'displays the gender of the relevant applicants' do
    render
    expect(rendered).to include "#{@gender}"
  end
  it 'provides a UNIX timestamp by which to sort the records' do
    render
    expect(rendered).to have_tag 'td',
                                 with: { 'data-order' =>
                                          @record1.created_at.to_i }
  end
end
