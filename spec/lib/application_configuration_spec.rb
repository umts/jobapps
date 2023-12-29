# frozen_string_literal: true

require 'rails_helper'
require 'application_configuration'

describe ApplicationConfiguration do
  describe 'configured_value' do
    def call(...)
      described_class.configured_value(...)
    end

    context 'with a value present in configuration' do
      before do
        allow(CONFIG).to receive(:dig).with(:present_key).and_return true
      end

      it 'returns the value' do
        expect(call [:present_key]).to be true
      end
    end

    context 'with a value not present in configuration' do
      before do
        allow(CONFIG).to receive(:dig).with(:missing_key).and_return({})
      end

      context 'with a default specified' do
        it 'returns the default' do
          expect(call [:missing_key], default: 'trees').to eq('trees')
        end
      end

      context 'without a default specified' do
        it 'raises an exception' do
          expect { call [:missing_key] }.to raise_error(ArgumentError)
        end
      end
    end
  end
end
