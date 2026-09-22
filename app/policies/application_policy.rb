# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  authorize :request
  authorize :user, allow_nil: true

  pre_check :allow_admins

  alias_rule :create?, to: :manage?
  alias_rule :new?, to: :create?
  alias_rule :edit?, to: :update?

  protected

  def staff_member? = user&.staff?

  def logged_in? = request.session[:entra_uid].present?

  private

  def allow_admins
    allow! if user&.admin?
  end
end
