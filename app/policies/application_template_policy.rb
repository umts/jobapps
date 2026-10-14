# frozen_string_literal: true

class ApplicationTemplatePolicy < ApplicationPolicy
  def manage? = allowed_to?(:manage?, record.position)

  def show? = logged_in?
end
