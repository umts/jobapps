# frozen_string_literal: true

class SessionPolicy < ApplicationPolicy
  def manage? = true
end
