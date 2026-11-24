# frozen_string_literal: true

class ChangeAccessControl < ActiveRecord::Migration[8.1]
  def change
    create_table :position_managers do |t|
      t.references :user, null: false, foreign_key: true, type: :integer
      t.references :position, null: false, foreign_key: true, type: :integer
      t.timestamps
      t.index %i[user_id position_id], unique: true
    end

    remove_reference :positions, :department, type: :integer, index: true, foreign_key: true

    remove_column :users, :staff, :boolean, default: false, null: false

    drop_table :departments, id: :integer do |t|
      t.datetime :created_at, precision: nil
      t.string :name, null: false
      t.datetime :updated_at, precision: nil
      t.index :name, unique: true
    end
  end
end
