class AddReplyToToApplicationDraft < ActiveRecord::Migration
  def change
    add_column :application_drafts, :reply_to, :string
    add_column :application_templates, :reply_to, :string
  end
end
