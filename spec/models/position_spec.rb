# frozen_string_literal: true

require 'rails_helper'

describe Position do
  describe '#name_and_department' do
    subject(:call) { position.name_and_department }

    let(:position) { build(:position) }

    it { is_expected.to include(position.name) }
    it { is_expected.to include(position.department.name) }
  end
end
