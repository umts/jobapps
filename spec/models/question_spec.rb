require 'spec_helper'
require 'rails_helper'

describe Question do
  context 'data_type identification methods' do
    before :each do
      @date = create :question, data_type: 'date'
      @explanation = create :question, data_type: 'explanation'
      @heading = create :question, data_type: 'heading'
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
end
