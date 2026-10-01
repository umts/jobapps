# frozen_string_literal: true

class InterviewPolicy < ApplicationPolicy
  def manage? = staff?
end
