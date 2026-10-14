# frozen_string_literal: true

class PositionPolicy < ApplicationPolicy
  relation_scope do |relation|
    next relation if admin?

    relation.joins(:position_managers).where(position_managers: { user: })
  end

  def manage? = manager_of?(record)

  def create? = false
end
