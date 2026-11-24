# frozen_string_literal: true

class PositionManagerPolicy < ApplicationPolicy
  def manage? = allowed_to?(:manage?, record.position)
end
