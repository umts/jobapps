# frozen_string_literal: true

class AddConstraintsToPositions < ActiveRecord::Migration[8.1]
  def change
    change_column_null :positions, :name, false
    change_column_null :positions, :department_id, false

    add_index :positions, :department_id
    add_foreign_key :positions, :departments
  end
end
