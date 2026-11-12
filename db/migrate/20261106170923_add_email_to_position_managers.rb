# frozen_string_literal: true

class AddEmailToPositionManagers < ActiveRecord::Migration[8.1]
  def change
    add_column :position_managers, :email, :boolean, default: false, null: false
  end
end
