# frozen_string_literal: true

class AddEntraUidToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :entra_uid, :string
    add_index :users, :entra_uid, unique: true
  end
end
