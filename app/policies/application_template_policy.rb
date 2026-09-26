# frozen_string_literal: true

class ApplicationTemplatePolicy < ApplicationPolicy
  def manage? = staff_member?

  def show? = logged_in?
end
