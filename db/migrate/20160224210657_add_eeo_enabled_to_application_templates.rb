class AddEeoEnabledToApplicationTemplates < ActiveRecord::Migration[4.2]
  def change
    add_column :application_templates, :eeo_enabled, :boolean, default: true
  end
end
