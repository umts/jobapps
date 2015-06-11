class ChangeSpireFromIntegerToString < ActiveRecord::Migration
  def change
    change_column :users, :spire, :string
  end
end
