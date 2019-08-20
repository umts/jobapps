class AddParentToUser < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :parent, index: true
    add_reference :users, :child, index: true
  end
end
