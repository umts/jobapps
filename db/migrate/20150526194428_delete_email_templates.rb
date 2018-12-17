class DeleteEmailTemplates < ActiveRecord::Migration[4.2]
  def change
    drop_table :email_templates
  end
end
