# frozen_string_literal: true

class AddConstraintsToApplicationSubmissions < ActiveRecord::Migration[8.1]
  def change
    change_column_null :application_submissions, :user_id, false
    change_column_null :application_submissions, :position_id, false
    change_column_null :application_submissions, :data, false
    change_column_null :application_submissions, :reviewed, false
    change_column_null :application_submissions, :saved_for_later, false

    add_foreign_key :application_submissions, :users
    add_foreign_key :application_submissions, :positions
  end
end
