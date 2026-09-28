# frozen_string_literal: true

class ApplicationTemplatePolicy < ApplicationPolicy
  def manage? = staff?

  def show? = logged_in?
end
