class AddSavedForLaterAndNoteForLaterToApplicationRecord < ActiveRecord::Migration
  def change
    add_column :application_records, :saved_for_later, :boolean
    add_column :application_records, :note_for_later, :text
  end
end
