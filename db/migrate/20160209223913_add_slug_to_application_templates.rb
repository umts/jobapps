class AddSlugToApplicationTemplates < ActiveRecord::Migration
  def change
    add_column :application_templates, :slug, :string
  end
end
