class RenameApplicationTemplateDraftToApplicationDraft < ActiveRecord::Migration[4.2]
  def change
    rename_table :application_template_drafts, :application_drafts
  end
end
