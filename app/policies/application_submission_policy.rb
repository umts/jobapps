# frozen_string_literal: true

class ApplicationSubmissionPolicy < ApplicationPolicy
  def manage? = staff?

  def show? = staff? || record.user == user

  def create? = logged_in?
end
