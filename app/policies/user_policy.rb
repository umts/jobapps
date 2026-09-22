# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def manage? = false
end
