# frozen_string_literal: true

class AddConstraintsToSubscriptions < ActiveRecord::Migration[8.1]
  def change
    change_column_null :subscriptions, :user_id, false
    change_column_null :subscriptions, :position_id, false
    change_column_null :subscriptions, :email, false

    add_foreign_key :subscriptions, :users
    add_foreign_key :subscriptions, :positions
  end
end
