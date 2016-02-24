class AddEeoEnabledToApplicationTemplates < ActiveRecord::Migration
  def change
    add_column :application_templates, :eeo_enabled, :string, default: true
  end
end
