# frozen_string_literal: true

require 'rails_helper'

describe ApplicationDataParser do
  describe 'result' do
    let :input do
      { 'prompt_0' => 'What is your name?',
        'response_0' => 'Luke Starkiller',
        'data_type_0' => 'text',
        '316' => '316-1' }
    end
    let(:output) { described_class.new(input).result }
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
end
