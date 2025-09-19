# frozen_string_literal: true

require 'rails_helper'

describe User do
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

  describe '#student?' do
    it 'returns true if user is not staff' do
      user = create(:user, staff: false)
      expect(user).to be_student
    end

    it 'returns false if user is staff' do
      user = create(:user, staff: true)
      expect(user).not_to be_student
    end
  end
end
