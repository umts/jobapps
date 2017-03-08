class RenameForeignKeyForUnavailabilities < ActiveRecord::Migration
  def change
    rename_column :unavailabilities, :application_record_id, :filed_application_id
  end
end
