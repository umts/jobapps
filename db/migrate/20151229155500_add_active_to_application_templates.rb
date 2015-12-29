class AddActiveToApplicationTemplates < ActiveRecord::Migration
  def change
    add_column :application_templates, :active, :boolean, default: true
  end
end
