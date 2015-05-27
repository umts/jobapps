class DeleteEmailTemplates < ActiveRecord::Migration
  def change
    drop_table :email_templates
  end
end
