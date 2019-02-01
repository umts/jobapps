class AddEmailToApplicationDrafts < ActiveRecord::Migration[4.2]
  def change
    add_column :application_drafts, :email, :string
    add_column :application_templates, :email, :string
  end
end
