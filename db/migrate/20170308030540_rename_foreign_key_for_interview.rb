class RenameForeignKeyForInterview < ActiveRecord::Migration
  def change
    rename_column :interviews, :application_record_id, :filed_application_id
  end
end
