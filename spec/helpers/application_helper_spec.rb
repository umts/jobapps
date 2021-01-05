# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper do
  describe 'parse_application_data' do
    let :input do
      { 'prompt_0' => 'What is your name?',
        'response_0' => 'Luke Starkiller',
        'data_type_0' => 'text',
        '316' => '316-1' }
    end
    let(:output) { parse_application_data input }
    let(:question_data) { output.first }
    it 'has the same size as the number of questions' do
      expect(output.length).to be 1
    end
    it 'puts the prompt in position 0' do
      expect(question_data[0]).to eql 'What is your name?'
    end
    it 'puts the response in position 1' do
      expect(question_data[1]).to eql 'Luke Starkiller'
    end
    it 'puts the data type in position 2' do
      expect(question_data[2]).to eql 'text'
    end
    it 'puts the question ID in position 3' do
      expect(question_data[3]).to be 316
    end
  end

  describe 'parse_unavailability' do
    let :input do
      { 'sunday_7AM' => '0', 'sunday_8AM' => '0', 'tuesday_11AM' => '1',
        'tuesday_12AM' => '1', 'friday_4PM' => '1', 'friday_5PM' => '0' }
    end
    let(:output) { parse_unavailability input }
    it 'does not select days that have no unavailabilities' do
      expect(output.keys).not_to include :sunday
    end
    it 'does select days that have unavailabilities' do
      expect(output.keys).to include :friday
    end
    it 'does not select available times on days with other unavailabilities' do
      expect(output[:friday]).not_to include '5PM'
    end
    it 'does select times on days with unavailabilities properly' do
      expect(output[:friday]).to include '4PM'
    end
  end
end
