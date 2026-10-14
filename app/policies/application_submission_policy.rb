# frozen_string_literal: true

class ApplicationSubmissionPolicy < ApplicationPolicy
  alias_rule :csv_export?, :eeo_data?, :past_applications?, to: :index?

  def index? = manager?

  def manage? = allowed_to?(:manage?, record.position)

  def show? = record.user == user || manage?

  def create? = logged_in?
end
