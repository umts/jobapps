# frozen_string_literal: true

require 'rails_helper'

describe Position do
  describe '#not_hiring' do
    subject(:call) { position.not_hiring }

    context 'with not hiring text' do
      let(:position) { build(:position, not_hiring_text: 'Check back in the spring.') }

      it { is_expected.to eq('Check back in the spring.') }
    end

    context 'with blank not hiring text' do
      let(:position) { build(:position, name: 'Operator', not_hiring_text: '') }

      it { is_expected.to eq('We are not currently hiring for Operator.') }
    end
  end
end
