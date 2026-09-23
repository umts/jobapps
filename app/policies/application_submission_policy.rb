# frozen_string_literal: true

class ApplicationSubmissionPolicy < ApplicationPolicy
  def manage? = staff_member?

  def create? = logged_in?

  def show? = logged_in? && (record.user == user || staff_member?)

  # Gates the record lookup in #show, which happens before the record-level
  # check and so must not be reachable unauthenticated.
  def lookup? = logged_in?
end
