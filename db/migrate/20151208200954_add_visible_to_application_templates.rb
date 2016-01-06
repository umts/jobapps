class AddVisibleToApplicationTemplates < ActiveRecord::Migration
  def change
    add_column :application_templates, :visible, :boolean, default: true
  end
end
