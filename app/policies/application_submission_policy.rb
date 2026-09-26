# frozen_string_literal: true

class ApplicationSubmissionPolicy < ApplicationPolicy
  def manage? = staff_member?

  def create? = logged_in?

  def show? = logged_in? && (record.user == user || staff_member?)
end
