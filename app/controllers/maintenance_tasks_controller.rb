# frozen_string_literal: true

class MaintenanceTasksController < ActionController::Base # rubocop:disable Rails/ApplicationController
  include Authorizable

  protected

  def implicit_authorization_target = :maintenance_tasks
end
