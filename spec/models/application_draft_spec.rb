# frozen_string_literal: true

require 'rails_helper'

describe ApplicationDraft do
  let(:draft) { create(:application_draft) }

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

    it { is_expected.to be(true) }

    context 'when a removed question left only its id behind' do
      let(:question_data) do
        [
          { number: 1, prompt: 'First', data_type: 'text', required: false },
          { id: question.id }
        ]
      end

      it { is_expected.to be(true) }

      it 'skips it' do
        call
        expect(draft.questions.reload.pluck(:prompt)).to eq(['First'])
      end
    end

    context 'when a question is missing its response type' do
      let(:question_data) do
        [
          { number: 1, prompt: 'Changed', data_type: 'text', required: false },
          { number: 2, prompt: 'No type', data_type: '', required: false }
        ]
      end

      before { create(:question, application_draft: draft, number: 1, prompt: 'Existing') }

      it { is_expected.to be(false) }

      it 'keeps the saved questions' do
        call
        expect(draft.questions.reload.pluck(:prompt)).to eq(['Existing'])
      end

      it 'says which question is invalid' do
        call
        expect(draft.errors.full_messages).to eq(["Question 2: Response type can't be blank"])
      end

      it 'does not save the email' do
        draft.email = 'drafts@example.com'
        call
        expect(draft.reload.email).to be_nil
      end
    end

    context 'when a question in the middle is left blank' do
      let(:question_data) do
        [
          { number: 1, prompt: 'First', data_type: 'text', required: false },
          { number: 2, prompt: '', data_type: '', required: false },
          { number: 3, prompt: 'Third', data_type: 'text', required: false }
        ]
      end

      it 'numbers the saved questions in order without a gap' do
        call
        expect(draft.questions.reload.pluck(:number, :prompt)).to eq([[1, 'First'], [2, 'Third']])
      end
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
