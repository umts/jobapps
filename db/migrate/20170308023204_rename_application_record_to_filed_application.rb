class RenameApplicationRecordToFiledApplication < ActiveRecord::Migration[4.6]
  def change
    rename_table :application_records, :filed_applications
  end
end
