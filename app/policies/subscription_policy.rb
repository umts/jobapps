# frozen_string_literal: true

class SubscriptionPolicy < ApplicationPolicy
  def manage? = allowed_to?(:manage?, record.position)
end
