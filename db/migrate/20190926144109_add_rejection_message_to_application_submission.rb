class AddRejectionMessageToApplicationSubmission < ActiveRecord::Migration[5.2]
  def change
    add_column :application_submissions, :rejection_message, :text
  end
end
