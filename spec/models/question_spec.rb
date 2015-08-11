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
  describe 'move' do
    before :each do
      @template = create :application_template
      @question_above = create :question,
                               application_template: @template,
                               number: 2
      @question = create :question,
                         application_template: @template,
                         number: 3
      @question_below = create :question,
                               application_template: @template,
                               number: 4
    end
    context 'moving up' do
      it 'decreases the question number by 1' do
        @question.move :up
        expect(@question.reload.number).to eql 2
      end
      it 'increases the number of the question above by 1' do
        @question.move :up
        expect(@question_above.reload.number). to eql 3
      end
      it 'does nothing if there is no question to swap with' do
        expect { @question_above.move :up }
          .not_to change { @question_above.number }
      end
    end # of context 'moving up'
    context 'moving down' do
      it 'increases the question number by 1' do
        @question.move :down
        expect(@question.reload.number).to eql 4
      end
      it 'decreases the number of the question below by 1' do
        @question.move :down
        expect(@question_below.reload.number). to eql 3
      end
    end
  end
end
