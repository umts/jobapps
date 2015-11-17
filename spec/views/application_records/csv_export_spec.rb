require 'rails_helper'
require 'csv'
include RSpecHtmlMatchers

describe 'application_records/csv_export.csv.erb' do
  before :each do
    # this test does not simply create an application record, because
    # it is supposed to be able to be run when an actual application
    # record's response data are serialized as either a hash or an array.
    # hence needing to hardcode an ID and all.
    @id = 1
    @prompt = 'A question'
    @response = 'An answer'
    record = double('record', id: @id, data: { @prompt => @response })
    assign :records, [record]
  end
  it 'displays comma separated id, prompt, and response for all records' do
    render
    data = CSV.parse(rendered, headers: true)
    expect(data.first.fetch 'Record Number').to eql @id.to_s
    expect(data.first.fetch 'Prompt').to eql @prompt
    expect(data.first.fetch 'Response').to eql @response
  end
end
