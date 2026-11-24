# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  def manage? = logged_in?
end
