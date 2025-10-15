# frozen_string_literal: true

require 'rails_helper'

describe ApplicationDraft do
  let(:draft) { create(:application_draft) }

  describe '#move_question' do
    subject :call do
      draft.move_question question_to_move.number, direction
    end

    let!(:question_above) { create(:question, application_draft: draft, number: 1) }
    let(:question_to_move) { create(:question, application_draft: draft, number: 2) }
    let!(:question_below) { create(:question, application_draft: draft, number: 3) }

    context 'when moving a question up' do
      let(:direction) { :up }

      it 'moves the question up by 1' do
        expect { call }.to change { question_to_move.reload.number }.by(-1)
      end

      it 'moves the question above down by 1' do
        expect { call }.to change { question_above.reload.number }.by(1)
      end

      it 'does not change the question below' do
        expect { call }.not_to(change { question_below.reload.number })
      end
    end

    context 'when moving a question down' do
      let(:direction) { :down }

      it 'moves the question in question down by 1' do
        expect { call }.to change { question_to_move.reload.number }.by(1)
      end

      it 'moves the question below up by 1' do
        expect { call }.to change { question_below.reload.number }.by(-1)
      end

      it 'does not change the question above' do
        expect { call }.not_to(change { question_above.reload.number })
      end
    end
  end

  describe '#new_question' do
    subject(:call) { draft.new_question }

    before do
      create_list(:question, 3, application_draft: draft) do |question, i|
        question.update!(number: i + 1)
      end
    end

    it { is_expected.to be_new_record }

    it 'initializes a new question for the draft' do
      expect(call.application_draft).to eq(draft)
    end

    it 'initializes a new question with the correct number' do
      expect(call.number).to be(4)
    end
  end

  describe '#remove_question' do
    subject :call do
      draft.remove_question question_to_remove.number
    end

    let!(:question_above) { create(:question, application_draft: draft, number: 1) }
    let(:question_to_remove) { create(:question, application_draft: draft, number: 2) }
    let!(:question_below) { create(:question, application_draft: draft, number: 3) }

    it 'removes the specified question' do
      call
      expect(draft.reload.questions).not_to include(question_to_remove)
    end

    it 'does not change the number of any questions above the one specified' do
      expect { call }.not_to(change { question_above.reload.number })
    end

    it 'moves questions below the specified question up by one' do
      expect { call }.to change { question_below.reload.number }.by(-1)
    end
  end

  describe '#update_questions' do
    subject(:call) { draft.update_questions question_data }

    let(:question) { create(:question, application_draft: draft) }
    let(:new_prompt) { 'A new prompt' }
    let(:question_data) do
      [
        {
          number: question.number,
          prompt: new_prompt,
          data_type: question.data_type,
          required: question.required
        },
        {
          number: question.number + 1,
          prompt: 'A prompt',
          data_type: 'text',
          required: true
        }
      ]
    end

    it 'erases old questions' do
      call
      expect(draft.questions).not_to include(question)
    end

    it 'creates new ones with the given data' do
      call
      expect(draft.questions.map(&:prompt)).to contain_exactly('A new prompt', 'A prompt')
    end
  end

  describe 'update_application_template!' do
    subject(:call) { draft.update_application_template! }

    let(:template) { create(:application_template) }
    let(:draft) { create(:application_draft, application_template: template) }

    it 'deletes all the questions in the template' do
      template_question = create(:question, application_template: template)
      call
      expect(template.reload.questions).not_to include(template_question)
    end

    it 'moves the draft questions over to the template' do
      draft_question = create(:question, application_draft: draft)
      call
      expect(template.reload.questions).to include(draft_question)
    end

    it 'destroys itself' do
      call
      expect(described_class.where(id: draft.id)).to be_empty
    end
  end
end
