require 'rails_helper'
include RSpecHtmlMatchers

describe 'application_records/past_application_records.haml' do
  before :each do
    @user1 = create :user, first_name: 'Rick', last_name: 'Cat'
    @record1 = create :application_record,
                       user: @user1,
                       staff_note: 'note'
    @records = [@record1]
    assign :records, @records
  end
  it 'displays a table of application records' do
    render
    expect(rendered).to have_tag 'table', with: { class: 'data_table' }
  end
  it 'displays the formatted creation date of the application records' do
    render
    expect(rendered).to include format_date_time @record1.created_at
  end
  it 'displays the proper name of the relevant applicants' do
    render
    expect(rendered).to include 'Cat, Rick'
  end
  it 'displays the staff note of the application records' do
    render
    expect(rendered).to include 'note'
  end
  it 'provides a UNIX timestamp by which to sort the records' do
    render
    expect(rendered).to have_tag 'td', 
      with: { 'data-order' => @record1.created_at.to_i}
  end
  context 'application record has an upcoming interview' do
    # an interview that has not been completed
    before :each do
      @record = create :application_record
      @interview = create :interview,
                           completed: false,
                           application_record: @record
    end
    it 'displays the date of the upcoming interview' do
      render
      expect(rendered).to include format_date_time @interview.scheduled
    end
  end
  context 'application record has a completed interview' do
    # an interview that has been completed
  end
  context 'application record has no interview' do
    # a record by itself without an interview
  end
end

# look at spec/views/application_records/show_spec for examples
