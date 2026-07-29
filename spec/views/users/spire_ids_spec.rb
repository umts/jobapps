# frozen_string_literal: true

require 'rails_helper'
require 'csv'

describe 'users/spire_ids' do
  subject(:data) { CSV.parse rendered, headers: true }

  let!(:user) { create(:user, spire: '87654321@umass.edu') }

  before do
    assign :users, User.where(id: user.id)
    render
  end

  it 'contains the spire id without the email domain' do
    expect(data.first.fetch('spire_id')).to eq('87654321')
  end

  it 'has one row per user' do
    expect(data.size).to be 1
  end
end
