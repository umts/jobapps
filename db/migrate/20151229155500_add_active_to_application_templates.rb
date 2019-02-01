class AddActiveToApplicationTemplates < ActiveRecord::Migration[4.2]
  def change
    add_column :application_templates, :active, :boolean, default: true
  end
end
