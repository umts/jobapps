# frozen_string_literal: true

# Route the MaintenanceTasks engine through our own controller so it inherits
# authentication and is restricted to admins (see MaintenanceTasksController).
MaintenanceTasks.parent_controller = 'MaintenanceTasksController'
