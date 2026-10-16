# frozen_string_literal: true

require 'rails_helper'

describe User do
  describe '#managed_positions' do
    it 'includes the positions the user manages' do
      manager = create(:position_manager)
      expect(manager.user.managed_positions).to contain_exactly(manager.position)
    end
  end

  describe '#full_name' do
    subject(:call) { user.full_name }

    let(:user) { build(:user) }

    it { is_expected.to eq("#{user.first_name} #{user.last_name}") }
  end

  describe '#proper_name' do
    subject(:call) { user.proper_name }

    let(:user) { build(:user) }

    it { is_expected.to eq("#{user.last_name}, #{user.first_name}") }
  end
end
