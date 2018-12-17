class ChangeSpireFromIntegerToString < ActiveRecord::Migration[4.2]
  def change
    change_column :users, :spire, :string
  end
end
