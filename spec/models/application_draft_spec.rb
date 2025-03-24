# frozen_string_literal: true

require 'rails_helper'

describe ApplicationDraft do
  describe 'move_question' do
    before do
      @draft = create(:application_draft)
      @question_above = create(:question, application_draft: @draft, number: 1)
      @question_to_move = create(:question, application_draft: @draft, number: 2)
      @question_below = create(:question, application_draft: @draft, number: 3)
      @number = @question_to_move.number
    end

    let :call do
      @draft.move_question @number, @direction
    end

    context 'direction is up' do
      before do
        @direction = :up
      end

      it 'moves the question up by 1' do
        expect { call }
          .to change { @question_to_move.reload.number }
          .by(-1)
      end

      it 'moves the question above down by 1' do
        expect { call }
          .to change { @question_above.reload.number }
          .by 1
      end

      it 'does not change the question below' do
        expect { call }
          .not_to change { @question_below.reload.number }
      end
    end

    context 'direction is down' do
      before do
        @direction = :down
      end

      it 'moves the question in question down by 1' do
        expect { call }
          .to change { @question_to_move.reload.number }
          .by 1
      end

      it 'moves the question below up by 1' do
        expect { call }
          .to change { @question_below.reload.number }
          .by(-1)
      end

      it 'does not change the question above' do
        expect { call }
          .not_to change { @question_above.reload.number }
      end
    end
  end

  describe 'new_question' do
    before do
      @draft = create(:application_draft)
      # Create three existing questions - the number of the new one should be 4
      create(:question, application_draft: @draft, number: 1)
      create(:question, application_draft: @draft, number: 2)
      create(:question, application_draft: @draft, number: 3)
    end

    let :call do
      @draft.new_question
    end

    it 'initializes a new question for the draft with the correct number' do
      expect(call.application_draft).to eql @draft
      expect(call.number).to be 4
      expect(call).to be_new_record
    end
  end

  describe 'remove_question' do
    before do
      @draft = create(:application_draft)
      @first_question  = create(:question, application_draft: @draft)
      @second_question = create(:question, application_draft: @draft)
      @third_question  = create(:question, application_draft: @draft)
    end

    let :call do
      @draft.remove_question @second_question.number
    end

    it 'removes the specified question' do
      call
      expect(@draft.reload.questions).not_to include @second_question
    end

    it 'does not change the number of any questions above the one specified' do
      expect { call }
        .not_to change { @first_question.reload.number }
    end

    it 'moves questions below the specified question up by one' do
      expect { call }
        .to change { @third_question.reload.number }
        .by(-1)
    end
  end

  describe 'update_questions' do
    before do
      @draft = create(:application_draft)
      @question = create(:question, application_draft: @draft)
      @new_prompt = 'A new prompt'
      @question_data = [
        {
          number: @question.number,
          prompt: 'A new prompt',
          data_type: @question.data_type,
          required: @question.required
        },
        {
          number: @question.number + 1,
          prompt: 'A prompt',
          data_type: 'text',
          required: true
        }
      ]
    end

    let :call do
      @draft.update_questions @question_data
    end

    it 'erases old questions and creates new ones with the given data' do
      call
      expect(@draft.questions.where(prompt: 'A new prompt')).to exist
      expect(@draft.questions.where(prompt: 'A prompt')).to exist
    end
  end

  describe 'update_application_template!' do
    before do
      @template = create(:application_template)
      @draft = create(:application_draft, application_template: @template)
      @template_question = create(:question, application_template: @template)
      @draft_question = create(:question, application_draft: @draft)
    end

    let :call do
      @draft.update_application_template!
    end

    it 'deletes all the questions in the template' do
      call
      expect(@template.reload.questions).not_to include @template_question
    end

    it 'moves the draft questions over to the template' do
      call
      expect(@template.reload.questions).to include @draft_question
    end

    it 'destroys itself' do
      call
      expect(described_class.where id: @draft.id).to be_empty
    end
  end
end
