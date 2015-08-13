class RenameApplicationTemplateDraftToApplicationDraft < ActiveRecord::Migration
  def change
    rename_table :application_template_drafts, :application_drafts
  end
end
