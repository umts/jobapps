# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe Question do
  describe 'validations' do
    let(:draft) { create(:application_draft) }
    let(:template) { create(:application_template) }

    it 'does not permit a question to belong to neither a draft or a template' do
      question = build(:question, application_draft: nil, application_template: nil)
      expect(question).not_to be_valid
    end

    it 'allows a question belonging only to a draft' do
      question = build(:question, application_draft: draft, application_template: nil)
      expect(question).to be_valid
    end

    it 'allows a question belonging only to a template' do
      question = build(:question, application_draft: nil, application_template: template)
      expect(question).to be_valid
    end

    it 'does not permit a question beloning to both a draft and a template' do
      question = build(:question, application_draft: draft, application_template: template)
      expect(question).not_to be_valid
    end
  end

  describe '#date?' do
    it 'returns true if data type is date' do
      question = build(:question, data_type: 'date')
      expect(question).to be_date
    end

    it 'returns false if data type is not date' do
      question = build(:question, data_type: 'explanation')
      expect(question).not_to be_date
    end
  end

  describe '#explanation?' do
    it 'returns true if data type is explanation' do
      question = build(:question, data_type: 'explanation')
      expect(question).to be_explanation
    end

    it 'returns false if data type is not explanation' do
      question = build(:question, data_type: 'heading')
      expect(question).not_to be_explanation
    end
  end

  describe '#heading?' do
    it 'returns true if data type is heading' do
      question = build(:question, data_type: 'heading')
      expect(question).to be_heading
    end

    it 'returns false if data type is not heading' do
      question = build(:question, data_type: 'date')
      expect(question).not_to be_heading
    end
  end

  describe '#takes_placeholder?' do
    %w[date text].each do |data_type|
      it "returns true for #{data_type}" do
        question = build(:question, data_type:)
        expect(question.takes_placeholder?).to be(true)
      end
    end

    %w[explanation heading number yes/no].each do |data_type|
      it "returns false for #{data_type}" do
        question = build(:question, data_type:)
        expect(question.takes_placeholder?).to be false
      end
    end
  end
end
