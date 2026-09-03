# frozen_string_literal: true

class MaintenanceTasksController < ActionController::Base # rubocop:disable Rails/ApplicationController
  include Authorizable

  before_action :allow_only_admin

  private

  def allow_only_admin
    raise Unauthorized unless Current.user&.admin?
  end
end
