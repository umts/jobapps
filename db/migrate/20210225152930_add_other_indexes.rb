class AddOtherIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :application_drafts, :application_template_id
    add_index :application_submissions, :user_id
    add_index :application_submissions, :position_id
    add_index :interviews, :user_id
    add_index :interviews, :application_submission_id
    add_index :subscriptions, :user_id
    add_index :unavailabilities, :application_submission_id
  end
end
