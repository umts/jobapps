class AddUnavailabilityEnabledToApplicationTemplates < ActiveRecord::Migration[4.2]
  def change
    add_column :application_templates, :unavailability_enabled, :boolean
  end
end
