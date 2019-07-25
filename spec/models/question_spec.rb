# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe Question do
  context 'validations' do
    # Yes that's right, ladies and gentlemen,
    # we are testing an XOR gate.
    before :each do
      @draft = create :application_draft
      @template = create :application_template
    end
    context 'question belonging to neither draft nor template' do
      it 'fails' do
        question = build :question,
                         application_draft: nil,
                         application_template: nil
        expect { question.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end
    context 'question belonging to draft but not template' do
      it 'passes' do
        question = build :question,
                         application_draft: @draft,
                         application_template: nil
        expect { question.save! }.not_to raise_error
      end
    end
    context 'questions belonging to template but not draft' do
      it 'passes' do
        question = build :question,
                         application_draft: nil,
                         application_template: @template
        expect { question.save! }.not_to raise_error
      end
    end
    context 'question belonging to both draft and template' do
      it 'fails' do
        question = build :question,
                         application_draft: @draft,
                         application_template: @template
        expect { question.save! }.to raise_error ActiveRecord::RecordInvalid
      end
    end
  end
  context 'data_type identification methods' do
    before :each do
      @template = create :application_template
    end
    before :each do
      @date = create :question, data_type: 'date',
                                application_template: @template
      @explanation = create :question, data_type: 'explanation',
                                       application_template: @template
      @heading = create :question, data_type: 'heading',
                                   application_template: @template
    end

    describe 'date?' do
      it 'returns true if data type is date' do
        expect(@date).to be_date
      end
      it 'returns false if data type is not date' do
        expect(@explanation).not_to be_date
      end
    end

    describe 'explanation?' do
      it 'returns true if data type is explanation' do
        expect(@explanation).to be_explanation
      end
      it 'returns false if data type is not explanation' do
        expect(@heading).not_to be_explanation
      end
    end

    describe 'heading?' do
      it 'returns true if data type is heading' do
        expect(@heading).to be_heading
      end
      it 'returns false if data type is not heading' do
        expect(@date).not_to be_heading
      end
    end
  end

  # I prefer not to write `to be takes_placeholder`
  # rubocop:disable UmtsCustomCops/PredicateMethodMatcher
  describe 'takes_placeholder?' do
    before :each do
      @draft = create :application_draft
    end
    it 'returns true for date, or text' do
      %w[date text].each do |data_type|
        question = create :question, application_draft: @draft,
                                     data_type: data_type
        expect(question.takes_placeholder?).to be true
      end
    end
    it 'returns false for explanation, heading, number, or yes/no' do
      %w[explanation heading number yes/no].each do |data_type|
        question = create :question, application_draft: @draft,
                                     data_type: data_type
        expect(question.takes_placeholder?).to be false
      end
    end
  end
  # rubocop:enable UmtsCustomCops/PredicateMethodMatcher
end
