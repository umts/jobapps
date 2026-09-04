# frozen_string_literal: true

class AddConstraintsToUnavailabilities < ActiveRecord::Migration[8.1]
  def change
    change_column_null :unavailabilities, :application_submission_id, false
    add_foreign_key :unavailabilities, :application_submissions
  end
end
