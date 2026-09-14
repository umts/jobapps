# frozen_string_literal: true

class AddEntraUpnToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :entra_upn, :string
  end
end
