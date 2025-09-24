# frozen_string_literal: true

require 'rails_helper'

describe 'markdown explanation' do
  before do
    when_current_user_is :staff
    visit markdown_explanation_path
  end

  it 'renders bold properly' do
    expect(page).to have_css('li strong', text: 'bold')
  end

  it 'renders italic properly' do
    expect(page).to have_css('li em', text: 'italic')
  end

  describe 'preview sandbox functionality' do
    it 'renders the bold markdown properly' do
      fill_in 'preview_input', with: '**Test bold text**'
      click_button 'Preview below'
      expect(page).to have_css('p strong', text: 'Test bold text')
    end

    it 'renders the italics markdown properly' do
      fill_in 'preview_input', with: '*Test italic text*'
      click_button 'Preview below'
      expect(page).to have_css('p em', text: 'Test italic text')
    end

    it 'renders the list markdown properly' do
      fill_in 'preview_input', with: '+ Test list element'
      click_button 'Preview below'
      expect(page).to have_css('ul li', text: 'Test list element')
    end
  end
end
