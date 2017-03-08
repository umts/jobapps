class RenameApplicationRecordToFiledApplication < ActiveRecord::Migration
  def change
    rename_table :application_records, :filed_applications
  end
end
