require 'rails_helper'

describe 'editing application draft' do
  let!(:draft){ create :application_draft }
  let!(:top_question){ create :question, number: 1, application_draft: draft }
  let!(:middle_question){ create :question, number: 2, application_draft: draft }
  let!(:bottom_question){ create :question, number: 3, application_draft: draft }
  before :each do
    when_current_user_is :staff, integration: true
    visit edit_draft_url(draft)
  end
  context 'moving questions' do
    it 'contains button to move middle question up' do
      page.all(:button,"Move up")[0].click
      # first button to move a question up is on question 2
      expect(middle_question.reload.number).to eql 1
    end 
    it 'contains button to move middle question down' do
      page.all(:button,"Move down")[1].click
      expect(middle_question.reload.number).to eql 3
    end
    it 'contains a button to move the top question down' do
      page.all(:button,"Move down")[0].click
      expect(top_question.reload.number).to eql 2
    end
    it 'contains a button to move the bottom question up' do
      page.all(:button,"Move up")[1].click
      expect(bottom_question.reload.number).to eql 2
    end
    it 'contains buttons to delete any question' do
      expect(page.all(:button, "Remove question").count).to eql 3
    end
  end
  it 'has inputs to edit the question prompts' do
    (0...draft.questions.count).each do |index|
      expect(page.has_field?("draft[questions_attributes][#{index}][prompt]",
                             type: 'textarea'))
    end
  end # of moving questions context
  it 'allows selection of the data type of the questions' do
    (0...draft.questions.count).each do |index|
      expect(page.has_field?("draft[questions_attributes][#{index}][data_type]",
                             type: 'select'))
    end
  end
  it 'has a checkbox to determine whether the question is required' do
    (0...draft.questions.count).each do |index|
      expect(page.has_field?("draft[questions_attributes][#{index}][required]",
                             type: 'checkbox'))
    end
  end
  it 'has a field to create a new question' do
    (0...draft.questions.count).each do |index|
      expect(page.has_field?("draft[questions_attributes][#{index + 1}][prompt]",
                             type: 'textarea'))
    # index + 1 would be the index of a question that does not exist yet
    end
  end
  it 'has a button to bring the user to a preview draft page' do
    click_button('Preview changes')
    expect(page.current_url).to eql draft_url(draft)
  end
  context 'clicking save changes and continue editing button' do
    it 'will add new questions to the draft' do
      # draft starts with 3 questions
      expect(draft.questions.count).to eql 3
      # fill in the prompt of the new question
      fill_in(all('textarea').last[:name], with: 'Stuff')
      # select a data type for the new question
      select 'text', from: all('select').last[:name]
      click_button('Save changes and continue editing')
      draft.reload
      expect(draft.questions.count).to eql 4
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
