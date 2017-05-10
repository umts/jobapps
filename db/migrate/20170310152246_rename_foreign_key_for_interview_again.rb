class RenameForeignKeyForInterviewAgain < ActiveRecord::Migration[5.0]
  def change
    rename_column :interviews, :filed_application_id, :application_submission_id
  end
end
