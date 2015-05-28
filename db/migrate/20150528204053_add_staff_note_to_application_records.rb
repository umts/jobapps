class AddStaffNoteToApplicationRecords < ActiveRecord::Migration
  def change
    add_column :application_records, :staff_note, :text
  end
end
