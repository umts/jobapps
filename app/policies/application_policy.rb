# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  authorize :request
  authorize :user, allow_nil: true

  pre_check :allow_admins

  alias_rule :edit?, to: :update?

  # Defined as methods rather than aliases so that rules resolve in one step and
  # subclasses can override them normally. ActionPolicy::Policy::Defaults ships
  # concrete false-returning index? and create?, which would otherwise shadow the
  # manage? default rule.
  def index? = manage?

  def create? = manage?

  def update? = manage?

  protected

  # admin is additive to staff in this app, as it was when these were two
  # separate before_actions.
  def admin? = user&.admin? && staff_member?

  def staff_member? = user&.staff?

  def logged_in? = request.session[:entra_uid].present?

  private

  def allow_admins
    allow! if admin?
  end
end
