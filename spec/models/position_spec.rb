# frozen_string_literal: true

require 'rails_helper'

describe Position do
  describe '#managers' do
    it 'includes the users who manage the position' do
      manager = create(:position_manager)
      expect(manager.position.managers).to contain_exactly(manager.user)
    end
  end
end
