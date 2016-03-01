class AddEeoEnabledToApplicationTemplates < ActiveRecord::Migration
  def change
    add_column :application_templates, :eeo_enabled, :boolean, default: true
  end
end
