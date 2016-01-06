require 'rails_helper'
include RSpecHtmlMatchers

describe 'application_records/past_applications.haml' do
  before :each do
    @user = create :user, first_name: 'Rick', last_name: 'Cat'
    @record = create :application_record,
                     user: @user,
                     staff_note: 'note'
    @records = [@record]
    assign :records, @records
  end
  it 'displays a table of application records' do
    render
    expect(rendered).to have_tag 'table', with: { class: 'data_table' }
  end
  it 'displays the formatted creation date of the application records' do
    render
    expect(rendered).to include format_date_time @record.created_at
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
                                 with: { 'data-order' =>
                                          @record.created_at.to_i }
  end
  context 'application record has an upcoming interview' do
    # an interview that has not been completed
    before :each do
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
    before :each do
      @note = 'interview note'
      @interview = create :interview,
                          completed: true,
                          application_record: @record,
                          interview_note: @note
    end
    it 'displays the date of the completed interview' do
      render
      expect(rendered).to include format_date_time @interview.scheduled
    end
    it 'displays a note about the interview' do
      render
      expect(rendered).to include @note
    end
  end
  context 'application record has no interview' do
    it 'tells the user that the interview is not scheduled' do
      render
      expect(rendered).to include 'not scheduled'
    end
  end
end
