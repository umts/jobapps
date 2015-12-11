require 'rails_helper'
include RSpecHtmlMatchers

describe 'application_records/_combined_totals.haml' do
  before :each do
    @combo = %w(Ethnicity Gender)
    combined = [@combo]
    assign :combined, combined
  end
  context 'applicants of every combination apply' do
    before :each do
      assign :combined_counts, @combo => 1
    end
    it 'displays total # of applicants of each ethnicity and gender combo' do
      render
      expect(rendered).to have_tag 'tr' do
        with_tag 'td', text: 'Ethnicity'
        with_tag 'td', text: 'Gender'
        with_tag 'td', text: '1'
      end
      expect(rendered).not_to have_tag 'td', text: '0'
    end
  end
  context 'not every combination of applicants apply' do
    before :each do
      assign :combined_counts, @combo => 0
    end
    it 'displays total # of applicants of each ethnicity and gender combo' do
      render
      expect(rendered).to have_tag 'tr' do
        with_tag 'td', text: 'Ethnicity'
        with_tag 'td', text: 'Gender'
        with_tag 'td', text: '0'
      end
      expect(rendered).not_to have_tag 'td', text: '1'
    end
  end
end
