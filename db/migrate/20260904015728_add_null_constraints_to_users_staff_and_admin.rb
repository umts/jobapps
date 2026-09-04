# frozen_string_literal: true

class AddNullConstraintsToUsersStaffAndAdmin < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :staff, false
    change_column_null :users, :admin, false
  end
end
