require 'rails_helper'
include RSpecHtmlMatchers

describe 'filed_applications/csv_export.csv.erb' do
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
    data = CSV.parse rendered, headers: true
    row = data.first
    expect(row.fetch 'Record Number').to eql @id.to_s
    expect(row.fetch 'Prompt').to eql @prompt
    expect(row.fetch 'Response').to eql @response
  end
  it 'has the correct number of lines' do
    render
    data = CSV.parse rendered, headers: true
    expect(data.size).to be 1
  end
end
