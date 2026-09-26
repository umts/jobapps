# frozen_string_literal: true

class ApplicationDraftPolicy < ApplicationPolicy
  def manage? = staff_member?
end
