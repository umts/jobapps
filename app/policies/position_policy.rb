# frozen_string_literal: true

class PositionPolicy < ApplicationPolicy
  def manage? = manager_of?(record)

  def create? = false
end
