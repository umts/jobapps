# frozen_string_literal: true

class DepartmentPolicy < ApplicationPolicy
  def manage? = staff_member?
end
