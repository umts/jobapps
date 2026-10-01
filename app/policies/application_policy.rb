# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  authorize :user, allow_nil: true

  pre_check :allow_admins

  alias_rule :create?, to: :manage?
  alias_rule :new?, to: :create?
  alias_rule :edit?, to: :update?

  protected

  def admin? = user&.admin?

  def staff? = user&.staff?

  def logged_in? = user.present?

  private

  def allow_admins
    allow! if admin?
  end
end
