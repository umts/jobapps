# frozen_string_literal: true

class MaintenanceTaskPolicy < ApplicationPolicy
  def manage? = false
end
