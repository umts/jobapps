require 'rails_helper'


# describe moving questions in here somewhat like this:
=begin
  describe 'move' do
    before :each do
      @template       = create :application_template
      @question_above = create :question,
                               application_template: @template,
                               number: 2
      @question       = create :question,
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
=end
