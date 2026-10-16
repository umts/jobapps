# frozen_string_literal: true

class CreatePositionManagers < ActiveRecord::Migration[8.1]
  def change
    create_table :position_managers do |t|
      t.references :user, null: false, foreign_key: true, type: :integer, index: false
      t.references :position, null: false, foreign_key: true, type: :integer
      t.timestamps
      t.index %i[user_id position_id], unique: true
    end
  end
end
