# frozen_string_literal: true

class PositionManager < ApplicationRecord
  belongs_to :user
  belongs_to :position

  validates :user_id, uniqueness: { scope: :position_id }
end
