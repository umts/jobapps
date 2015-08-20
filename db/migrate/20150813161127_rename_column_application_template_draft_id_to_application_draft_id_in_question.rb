class RenameColumnApplicationTemplateDraftIdToApplicationDraftIdInQuestion < ActiveRecord::Migration
  def change
    rename_column :questions, :application_template_draft_id, :application_draft_id
  end
end
