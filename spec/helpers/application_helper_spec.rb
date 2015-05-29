require 'rails_helper'

describe ApplicationHelper do
  describe 'show_message' do
    context 'message present in configuration' do
      it 'stores specified message in flash'
    end
    context 'message not present in configuration' do
      context 'default specified' do
        it 'stores given default message in flash'
      end
      context 'default not specified' do
        it 'raises an ArgumentError'
      end
    end
  end
  describe 'text' do
    before :each do
      @site_text = create :site_text
    end
    it 'renders a site text if it exists' do
      expect(text @site_text.name).not_to be_blank
    end
    it 'renders nothing if a site text does not exist' do
      expect(text 'some random string').to be_blank
    end
  end
end
