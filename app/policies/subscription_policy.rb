# frozen_string_literal: true

class SubscriptionPolicy < ApplicationPolicy
  def manage? = staff_member?
end
