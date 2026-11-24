# frozen_string_literal: true

class SessionsController < UMTS::Auth::SessionsController
  after_login do
    User.create_with(email: session[:entra_email])
        .find_or_initialize_by(entra_uid: session[:entra_uid])
        .update!({ first_name: session[:entra_first_name],
                   last_name: session[:entra_last_name],
                   entra_upn: session[:entra_upn] }.compact_blank)
  end
end
