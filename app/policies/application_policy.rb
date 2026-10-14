# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  authorize :user, allow_nil: true

  pre_check :allow_admins

  alias_rule :create?, to: :manage?
  alias_rule :new?, to: :create?
  alias_rule :edit?, to: :update?

  protected

  def admin? = user&.admin?

  def logged_in? = user.present?

  def manager? = user&.position_managers&.any?

  def manager_of?(position)
    position.is_a?(Position) && user&.position_managers&.any? { |pm| pm.position_id == position.id }
  end

  private

  def allow_admins
    allow! if admin?
  end
end
