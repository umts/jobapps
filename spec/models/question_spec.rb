require 'spec_helper'
require 'rails_helper'

describe Question do
  before :each do
    @template = create :application_template
  end
  context 'data_type identification methods' do
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
        expect(@date.date?).to eql true
      end
      it 'returns false if data type is not date' do
        expect(@explanation.date?).to eql false
      end
    end

    describe 'explanation?' do
      it 'returns true if data type is explanation' do
        expect(@explanation.explanation?).to eql true
      end
      it 'returns false if data type is not explanation' do
        expect(@heading.explanation?).to eql false
      end
    end

    describe 'heading?' do
      it 'returns true if data type is heading' do
        expect(@heading.heading?).to eql true
      end
      it 'returns false if data type is not heading' do
        expect(@date.heading?).to eql false
      end
    end
  end

  describe 'takes_placeholder?' do
    before :each do
      @draft = create :application_draft
    end
    it 'returns true for date, or text' do
      %w(date text).each do |data_type|
        question = create :question, application_draft: @draft,
                                     data_type: data_type
        expect(question.takes_placeholder?).to eql true
      end
    end
    it 'returns false for explanation, heading, number, or yes/no' do
      %w(explanation heading number yes/no).each do |data_type|
        question = create :question, application_draft: @draft,
                                     data_type: data_type
        expect(question.takes_placeholder?).to eql false
      end
    end
  end
end
