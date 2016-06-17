class AddUnavailabilityEnabledToApplicationTemplates < ActiveRecord::Migration
  def change
    add_column :application_templates, :unavailability_enabled, :boolean
  end
end
