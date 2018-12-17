class CreatePositions < ActiveRecord::Migration[4.2]
  def change
    create_table :positions do |t|
      t.integer :department_id
      t.string :name
      t.timestamps
    end
  end
end
