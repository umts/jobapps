# frozen_string_literal: true

class PositionPolicy < ApplicationPolicy
  def manage? = staff_member?
end
