# frozen_string_literal: true

class InterviewPolicy < ApplicationPolicy
  def manage? = allowed_to?(:manage?, record.position)
end
