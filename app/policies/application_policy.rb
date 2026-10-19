# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  include UMTS::Auth::Policy

  pre_check :allow_admins

  protected

  def admin? = user&.admin?

  def staff? = user&.staff?

  def logged_in? = user.present?

  private

  def allow_admins
    allow! if admin?
  end
end
