require 'rails_helper'
include RSpecHtmlMatchers

describe 'application_records/eeo_data.haml' do
  before :each do
    @ethnicity = 'ethnicity'
    @gender = 'gender'
    @record = create :application_record,
                     ethnicity: @ethnicity,
                     gender: @gender
    combined_counts = { [@ethnicity, @gender] => 1, %w(Ferengi Female) => 2 }
    records = [@record]
    genders = [@gender, 'female']
    ethnicities = [@ethnicity, 'Ferengi']
    combined = [[ethnicities], [genders]]
    assign :records, records
    assign :ethnicity_counts, @ethnicity => 1, 'Ferengi' => 2
    assign :gender_counts, @gender => 1, 'female' => 2
    assign :combined_counts, combined_counts
    assign :ethnicities, ethnicities
    assign :genders, genders
    assign :combined, combined
  end
  it 'displays a table of application records' do
    render
    expect(rendered).to have_tag 'table', with: { class: 'data_table' }
  end
  it 'displays the formatted creation date of the application records' do
    render
    expect(rendered).to include format_date_time @record.created_at
  end
  it 'displays the ethnicity of the relevant applicants' do
    render
    expect(rendered).to include @ethnicity
  end
  it 'displays the gender of the relevant applicants' do
    render
    expect(rendered).to include @gender
  end
  it 'provides a UNIX timestamp by which to sort the records' do
    render
    expect(rendered).to have_tag 'td',
                                 with: { 'data-order' =>
                                          @record.created_at.to_i }
  end
  it 'displays a list of all ethnicities' do
    render
    expect(rendered).to include 'Ferengi'
  end
end
