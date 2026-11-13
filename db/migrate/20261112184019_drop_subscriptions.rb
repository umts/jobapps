# frozen_string_literal: true

class DropSubscriptions < ActiveRecord::Migration[8.1]
  def change
    reversible do |dir|
      dir.up do
        drop_table :subscriptions
      end

      dir.down do
        create_table :subscriptions, force: :cascade do |t|
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
  end
end
