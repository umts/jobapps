# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  def manage? = staff_member?

  def main? = logged_in?

  def student? = logged_in?
end
