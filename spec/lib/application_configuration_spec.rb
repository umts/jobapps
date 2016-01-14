require 'rails_helper'
include ApplicationConfiguration

describe ApplicationConfiguration do
  describe 'configured_value' do
    context 'value present in configuration' do
      before :each do
        expect(CONFIG).to receive(:[]).with(:present_key).and_return true
      end
      it 'returns the value' do
        expect(configured_value [:present_key]).to be true
      end
    end
    context 'value not present in configuration' do
      before :each do
        expect(CONFIG).to receive(:[]).with(:missing_key).and_return Hash.new
      end
      context 'default specified' do
        it 'returns the default' do
          expect(configured_value [:missing_key], default: 'trees')
            .to eql 'trees'
        end
      end
      context 'default not specified' do
        it 'raises an exception' do
          expect { configured_value [:missing_key] }
            .to raise_error(ArgumentError)
        end
      end
    end
  end
end
