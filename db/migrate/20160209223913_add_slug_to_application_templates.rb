class AddSlugToApplicationTemplates < ActiveRecord::Migration[4.2]
  def change
    add_column :application_templates, :slug, :string
  end
end
