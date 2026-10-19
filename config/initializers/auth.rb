# frozen_string_literal: true

UMTS::Auth.development_login_users = lambda {
  { 'Admins' => User.where(admin: true),
    'Staff' => User.where(admin: false, staff: true).distinct,
    'Applicants' => User.where(admin: false, staff: false).distinct }
}
