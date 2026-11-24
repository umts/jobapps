# frozen_string_literal: true

class ApplicationTemplatePolicy < ApplicationPolicy
  def manage? = allowed_to?(:manage?, record.position)
end
