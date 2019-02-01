require 'rails_helper'

describe 'editing application draft' do
  let!(:draft) { create :application_draft }
  let!(:top_question) do
    create :question, number: 1,
                      application_draft: draft
  end
  let!(:middle_question) do
    create :question, number: 2,
                      application_draft: draft
  end
  let!(:bottom_question) do
    create :question, number: 3,
                      application_draft: draft
  end
  before :each do
    when_current_user_is :staff, integration: true
    visit edit_draft_url(draft)
  end
  context 'moving questions' do
    it 'contains button to move middle question up' do
      page.all(:button, 'Move up')[0].click
      # first button to move a question up is on question 2
      expect(middle_question.reload.number).to be 1
    end
    it 'contains button to move middle question down' do
      page.all(:button, 'Move down')[1].click
      expect(middle_question.reload.number).to be 3
    end
    it 'contains a button to move the top question down' do
      page.all(:button, 'Move down')[0].click
      expect(top_question.reload.number).to be 2
    end
    it 'contains a button to move the bottom question up' do
      page.all(:button, 'Move up')[1].click
      expect(bottom_question.reload.number).to be 2
    end
    it 'contains buttons to delete any question' do
      expect(page.all(:button, 'Remove question').count).to be 3
    end
  end
  it 'has inputs to edit the question prompts' do
    (0...draft.questions.count).each do |index|
      expect(page.has_field?("draft[questions_attributes][#{index}][prompt]",
                             type: 'textarea'))
    end
  end # of moving questions context
  it 'allows selection of the data type of each question' do
    all('select').each do |field|
      page.has_select?(field[:name], options: Question::DATA_TYPES)
    end
  end
  it 'has a checkbox to determine whether the question is required' do
    boxes = all("form[action='#{draft_path(draft)}'] input[type=checkbox]")
            .select do |box|
      box[:name].include? 'required'
    end
    expect(boxes.count).to eql draft.questions.count + 1
    # there is a checkbox to determine whether the new
    # question is required or not, thus there will be one
    # more checkbox than there are existing questions
  end
  it 'has a field to create a new question' do
    expect(all('.field-attribute textarea').count).to be 4
    # there are 3 existing questions, the 4th textarea field is for a new one
    expect(all('.field-attribute textarea').last.value).to be_empty
    # and it should contain no existing text
  end
  it 'has a button to bring the user to a preview draft page' do
    click_button('Preview changes')
    expect(page.current_url).to eql draft_url(draft)
  end
  context 'clicking save changes and continue editing button' do
    it 'will add new questions to the draft' do
      # draft starts with 3 questions
      expect(draft.questions.count).to be 3
      # fill in the prompt of the new question by finding
      # the last one on the page by its name
      fill_in(all('.field-attribute textarea').last[:name], with: 'Stuff')
      # select a data type for the new question
      select 'text', from: all('select').last[:name]
      click_button('Save changes and continue editing')
      draft.reload
      expect(draft.questions.count).to be 4
      expect(draft.questions.last.prompt).to eql 'Stuff'
    end
    it 'will save changes made to questions' do
      expect(draft.questions.first.prompt).to eql 'Question prompt'
      # change the prompt of one of the questions
      fill_in(all('textarea').first[:name], with: 'A different prompt')
      click_button('Save changes and continue editing')
      expect(draft.reload.questions.first.prompt).to eql 'A different prompt'
    end
  end
end
