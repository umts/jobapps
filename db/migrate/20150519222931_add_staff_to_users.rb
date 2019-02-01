class AddStaffToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :staff, :boolean
  end
end
