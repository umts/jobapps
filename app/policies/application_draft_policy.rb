# frozen_string_literal: true

class ApplicationDraftPolicy < ApplicationPolicy
  def manage? = allowed_to?(:manage?, record.position)
end
