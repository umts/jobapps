class AddApplicationSubmissionIdUniquenessConstraintToInterviews < ActiveRecord::Migration[6.1]
  def change
    remove_index :interviews, :application_submission_id
    add_index :interviews, :application_submission_id, unique: true
  end
end
