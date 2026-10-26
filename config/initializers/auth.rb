# frozen_string_literal: true

UMTS::Auth.development_login_users = lambda {
  { 'Admins' => User.where(admin: true),
    'Staff' => User.where(admin: false).joins(:managed_positions).distinct,
    'Applicants' => User.where(admin: false).where.missing(:managed_positions).distinct }
}
