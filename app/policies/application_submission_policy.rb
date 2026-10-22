# frozen_string_literal: true

class ApplicationSubmissionPolicy < ApplicationPolicy
  def manage? = allowed_to?(:manage?, record.position)

  def show? = record.user == user || manage?

  def create? = logged_in?
end
