# frozen_string_literal: true

class MoveSubscriptionsToPositionManagers < ActiveRecord::Migration[8.1]
  def change
    add_column :position_managers, :email, :boolean, default: true, null: false
    drop_table :subscriptions do |t|
      t.integer "user_id", null: false
      t.integer "position_id", null: false
      t.string "email", null: false
      t.datetime "created_at", precision: nil, null: false
      t.datetime "updated_at", precision: nil, null: false
      t.index ["position_id", "email"], name: "index_subscriptions_on_position_id_and_email", unique: true
      t.index ["user_id"], name: "index_subscriptions_on_user_id"
    end
  end
end
