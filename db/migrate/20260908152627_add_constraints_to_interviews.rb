# frozen_string_literal: true

class AddConstraintsToInterviews < ActiveRecord::Migration[8.1]
  def change
    change_column_null :interviews, :user_id, false
    change_column_null :interviews, :application_submission_id, false
    change_column_null :interviews, :completed, false
    change_column_null :interviews, :hired, false
    change_column_null :interviews, :scheduled, false
    change_column_null :interviews, :location, false

    add_foreign_key :interviews, :users
    add_foreign_key :interviews, :application_submissions
  end
end
