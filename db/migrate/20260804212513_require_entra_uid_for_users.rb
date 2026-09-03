# frozen_string_literal: true

class RequireEntraUidForUsers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :entra_uid, false
  end
end
