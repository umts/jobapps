class AddUserIdToApplicationTemplateDrafts < ActiveRecord::Migration
  def change
    add_column :application_template_drafts, :user_id, :integer
  end
end
