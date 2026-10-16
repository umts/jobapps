# frozen_string_literal: true

class DropDepartmentsAndStaff < ActiveRecord::Migration[8.1]
  def change
    remove_reference :positions, :department, type: :integer, index: true, foreign_key: true

    drop_table :departments, id: :integer do |t|
      t.datetime :created_at, precision: nil
      t.string :name, null: false
      t.datetime :updated_at, precision: nil
      t.index :name, unique: true
    end

    remove_column :users, :staff, :boolean, default: false, null: false
  end
end
