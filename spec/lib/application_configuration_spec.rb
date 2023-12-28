# frozen_string_literal: true

require 'rails_helper'
require 'application_configuration'

describe ApplicationConfiguration do
  describe 'configured_value' do
    context 'value present in configuration' do
      before do
        expect(CONFIG).to receive(:dig).with(:present_key).and_return true
      end

      it 'returns the value' do
        expect(subject.configured_value [:present_key]).to be true
      end
    end

    context 'value not present in configuration' do
      before do
        expect(CONFIG).to receive(:dig).with(:missing_key).and_return({})
      end

      context 'default specified' do
        it 'returns the default' do
          expect(subject.configured_value [:missing_key], default: 'trees')
            .to eql 'trees'
        end
      end

      context 'default not specified' do
        it 'raises an exception' do
          expect { subject.configured_value [:missing_key] }
            .to raise_error(ArgumentError)
        end
      end
    end
  end
end
