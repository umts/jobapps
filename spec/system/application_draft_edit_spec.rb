# frozen_string_literal: true

require 'rails_helper'

describe 'editing application draft' do
  let!(:draft) { create(:application_draft) }
  let!(:top_question) { create(:question, number: 1, application_draft: draft) }
  let!(:middle_question) { create(:question, number: 2, application_draft: draft) }
  let!(:bottom_question) { create(:question, number: 3, application_draft: draft) }

  before do
    when_current_user_is :staff
    visit edit_draft_path(draft)
  end

  context 'viewing page' do
    it 'has inputs to edit the question prompts' do
      (0...draft.questions.count).each do |index|
        expect(page.has_field?("draft[questions_attributes][#{index}][prompt]", type: 'textarea'))
      end
    end

    it 'allows selection of the data type of each question' do
      all('select').each do |field|
        page.has_select?(field[:name], options: Question::DATA_TYPES)
      end
    end

    it 'has a checkbox to determine whether the question is required' do
      boxes = all("form[action='#{draft_path(draft)}'] input[type=checkbox]").select do |box|
        box[:name].include? 'required'
      end
      expect(boxes.count).to eql draft.questions.count + 1
      # there is a checkbox to determine whether the new
      # question is required or not, thus there will be one
      # more checkbox than there are existing questions
    end

    it 'has a field to create a new question' do
      expect(find_all('#fields-container .row.field-row').count).to be 4
      # there are 3 existing questions, the 4th textarea field is for a new one
      expect(find_all('#fields-container .row.field-row textarea').last.value).to be_empty
      # and it should contain no existing text
    end

    it 'has a button to bring the user to a preview draft page' do
      click_button('Preview changes')
      expect(page.current_path).to eql draft_path(draft)
    end
  end

  context 'clicking save changes and continue editing button' do
    it 'adds new questions to the draft' do
      # draft starts with 3 questions
      expect(draft.questions.count).to be 3
      # fill in the prompt of the new question by finding
      # the last one on the page by its name
      field = find_all('#fields-container textarea')[3][:name]
      fill_in(field, with: 'Stuff')
      # select a data type for the new question
      select 'text', from: find_all('#fields-container select').last[:name]
      click_button('Save changes and continue editing')
      draft.reload
      expect(draft.questions.count).to be 4
      expect(draft.questions.last.prompt).to eql 'Stuff'
    end

    it 'saves changes made to questions' do
      expect(draft.questions.first.prompt).to eql 'Question prompt'
      # change the prompt of one of the questions
      fill_in(all('textarea').first[:name], with: 'A different prompt')
      click_button('Save changes and continue editing')
      expect(draft.reload.questions.first.prompt).to eql 'A different prompt'
    end
  end
end
