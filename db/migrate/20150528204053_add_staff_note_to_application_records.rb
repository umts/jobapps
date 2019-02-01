class AddStaffNoteToApplicationRecords < ActiveRecord::Migration[4.2]
  def change
    add_column :application_records, :staff_note, :text
  end
end
