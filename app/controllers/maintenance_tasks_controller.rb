# frozen_string_literal: true

class MaintenanceTasksController < ActionController::Base # rubocop:disable Rails/ApplicationController
  include Authorizable

  # The engine's controllers inherit from this one and define the actions,
  # so there is no action body here to authorize from.
  before_action :authorize!

  protected

  def implicit_authorization_target = :maintenance_tasks
end
