# frozen_string_literal: true

class AddNullConstraintsToUsers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :email, false
    change_column_null :users, :first_name, false
    change_column_null :users, :last_name, false
    change_column_null :users, :staff, false, false
    change_column_null :users, :admin, false, false
  end
end
