class CreateSubscriptions < ActiveRecord::Migration[4.2]
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.integer :position_id
      t.string :email

      t.timestamps null: false
    end
  end
end
