class RenameForeignKeyForUnavailabilities < ActiveRecord::Migration[5.0]
  def change
    rename_column :unavailabilities, :application_record_id, :filed_application_id
  end
end
