class RenameFiledApplicationToApplicationSubmission < ActiveRecord::Migration[5.0]
  def change
    rename_table :filed_applications, :application_submissions
  end
end
