require 'rails_helper'

describe 'adding questions' do
  let(:draft) { create :application_draft }
  before :each do
    when_current_user_is :staff, integration: true
    visit edit_draft_path(draft) 
  end

  context 'with all required fields' do
    it 'adds the question to the draft' do
      fill_in 'draft[questions_attributes][0][prompt]',
        with: 'What is your favorite color?'
      select 'text', from: 'draft[questions_attributes][0][data_type]'
      expect { click_on 'Save changes and continue editing' }
        .to change { draft.questions.reload.count }.by 1
    end
  end
  
end
