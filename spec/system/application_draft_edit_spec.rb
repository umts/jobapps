# frozen_string_literal: true

require 'rails_helper'

describe 'editing application draft' do
  let!(:draft) { create(:application_draft) }

  before do
    create_list(:question, 3, application_draft: draft) do |question, i|
      question.update(number: i + 1)
    end
    when_current_user_is :staff
    visit edit_draft_path(draft)
  end

  context 'when viewing the application draft' do
    it 'has inputs to edit the question prompts' do
      (0...draft.questions.count).each do |index|
        expect(page).to have_field("draft[questions_attributes][#{index}][prompt]", type: 'textarea')
      end
    end

    it 'allows selection of the data type of each question' do
      (0...draft.questions.count).each do |index|
        expect(page).to have_select("draft[questions_attributes][#{index}][data_type]",
                                    with_options: Question::DATA_TYPES)
      end
    end

    it 'has a checkbox to determine whether the question is required' do
      (0...draft.questions.count).each do |index|
        expect(page).to have_field("draft[questions_attributes][#{index}][required]", type: 'checkbox')
      end
    end

    it 'has a field to create a new question' do
      # there are 3 existing questions, the 4th textarea field is for a new one
      expect(page).to have_css('#fields-container .row.field-row textarea', count: 4)
    end

    it 'has a blank field for the new question' do
      within('#fields-container .row.field-row:last-child') do
        expect(page).to have_field(type: 'textarea', with: '')
      end
    end

    it 'has a button to bring the user to a preview draft page' do
      click_button('Preview changes')
      expect(page).to have_current_path(draft_path(draft))
    end
  end

  describe 'adding a new question' do
    before do
      # fill in the prompt of the new question by finding
      # the last one on the page by its name
      within('#fields-container .row.field-row:last-child') do
        fill_in(find('textarea')[:name], with: 'Stuff')
        select 'text', from: find('select')[:name]
      end
    end

    it 'adds a new question to the draft' do
      click_button('Save changes and continue editing')
      expect(draft.reload.questions.count).to be(4)
    end

    it 'saves the new question with the correct attributes' do
      click_button('Save changes and continue editing')
      expect(draft.reload.questions.last.prompt).to eq('Stuff')
    end
  end

  describe 'editing an existing question' do
    before do
      within('#fields-container .row.field-row:first-child') do
        fill_in(find('textarea')[:name], with: 'A different prompt')
      end
    end

    it 'saves changes made to questions' do
      click_button('Save changes and continue editing')
      expect(draft.reload.questions.first.prompt).to eql 'A different prompt'
    end
  end
end
