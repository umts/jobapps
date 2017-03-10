class RenameForeignKeyForUnavailabilitiesAgain < ActiveRecord::Migration[5.0]
  def change
    rename_column :unavailabilities, :filed_application_id, :application_submission_id
  end
end
