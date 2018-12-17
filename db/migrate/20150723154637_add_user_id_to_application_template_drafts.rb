class AddUserIdToApplicationTemplateDrafts < ActiveRecord::Migration[4.2]
  def change
    add_column :application_template_drafts, :user_id, :integer
  end
end
