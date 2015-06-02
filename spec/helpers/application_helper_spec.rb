require 'rails_helper'

describe ApplicationHelper do
  describe 'show_message' do
    before :each do
      #Replace actual config with these messages
      messages = {present_message: 'present value'}
      #Stub it out to return these messages
      expect(CONFIG).to receive(:[]).with(:messages).and_return messages
    end
    context 'message present in configuration,' do
      it 'stores specified message in flash' do
        show_message :present_message
        expect(flash[:message]).to eql 'present value'
      end
    end
    context 'message not present in configuration,' do
      context 'default specified,' do
        it 'stores given default message in flash' do
          show_message :missing_message, default: 'default value'
          expect(flash[:message]).to eql 'default value'
        end
      end
      context 'default not specified,' do
        it 'raises an ArgumentError' do
          expect{show_message :missing_message}.to raise_error(ArgumentError)
        end
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
