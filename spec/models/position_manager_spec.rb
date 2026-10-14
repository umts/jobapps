# frozen_string_literal: true

require 'rails_helper'

describe PositionManager do
  subject(:manager) { create(:position_manager) }

  it { is_expected.to be_valid }

  it 'only lets a user manage a position once' do
    duplicate = build(:position_manager, user: manager.user, position: manager.position)
    expect(duplicate).not_to be_valid
  end
end
