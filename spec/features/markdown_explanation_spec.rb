# frozen_string_literal: true

require 'rails_helper'

describe 'markdown explanation' do
  before :each do
    when_current_user_is :staff, integration: true
    visit markdown_explanation_path
  end
  context 'markdown explanation renders properly' do
    it 'renders bold properly' do
      expect(find('li//strong', text: 'bold'))
    end
    it 'renders italic properly' do
      expect(find('li//em', text: 'italic'))
    end
  end
  context 'markdown editor renders text properly' do
    it 'renders the bold markdown properly' do
      fill_in 'preview_input', with: '**Test bold text**'
      click_button 'Preview below'
      expect(find('p//strong', text: 'Test bold text'))
    end
    it 'renders the italics markdown properly' do
      fill_in 'preview_input', with: '*Test italic text*'
      click_button 'Preview below'
      expect(find('p//em', text: 'Test italic text'))
    end
    it 'renders the list markdown properly' do
      fill_in 'preview_input', with: '+ Test list element'
      click_button 'Preview below'
      expect(find('ul//li', text: 'Test list element'))
    end
  end
end