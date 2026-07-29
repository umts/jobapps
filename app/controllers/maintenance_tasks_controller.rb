# frozen_string_literal: true

# Parent controller for the MaintenanceTasks engine (see
# config/initializers/maintenance_tasks.rb). Inherits authentication from
# ApplicationController and restricts the engine to admins, since tasks like
# ImportEntraUidsTask can overwrite user identities.
class MaintenanceTasksController < ApplicationController
  layout 'maintenance_tasks/application'

  before_action :allow_only_admin

  private

  def allow_only_admin
    deny_access unless Current.user&.admin?
  end
end
