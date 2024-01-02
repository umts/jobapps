# frozen_string_literal: true

require 'rails_helper'
require 'csv'

describe 'application_submissions/csv_export.csv.erb' do
  subject(:data) { CSV.parse rendered, headers: true }

  let(:prompt) { 'A question' }
  let(:response) { 'An answer' }

  let :record do
    # this test does not simply create an application record, because
    # it is supposed to be able to be run when an actual application
    # record's response data are serialized as either a hash or an array.
    # hence needing to hardcode an ID and all.
    rec = Struct.new(:id, :data)
    rec.new(1, { prompt => response })
  end

  before do
    assign :records, [record]
    render
  end

  it 'contains the id of the record' do
    expect(data.first.fetch 'Record Number').to eq(record.id.to_s)
  end

  it 'containts the prompt of the question' do
    expect(data.first.fetch 'Prompt').to eq(prompt)
  end

  it 'contains the answer to the question' do
    expect(data.first.fetch 'Response').to eq(response)
  end

  it 'has the correct number of lines' do
    expect(data.size).to be 1
  end
end
