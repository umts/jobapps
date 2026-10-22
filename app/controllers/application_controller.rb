# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authorizable

  def show_errors(object)
    flash[:errors] = object.errors.full_messages
    redirect_back_or_to root_path
  end
end
