# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  include UMTS::Auth::Policy

  pre_check :allow_admins

  protected

  def admin? = user&.admin?

  def manager_of?(position) = user&.managed_positions&.include?(position)

  def logged_in? = user.present?

  private

  def allow_admins
    allow! if admin?
  end
end
