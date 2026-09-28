# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  def manage? = staff?

  def main? = logged_in?

  def student? = logged_in?
end
