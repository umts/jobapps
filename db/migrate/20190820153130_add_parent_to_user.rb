class AddParentToUser < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :parent, index: true
  end
end
