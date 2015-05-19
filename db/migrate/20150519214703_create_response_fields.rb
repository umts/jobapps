class CreateResponseFields < ActiveRecord::Migration
  def change
    create_table :response_fields do |t|
      t.string :name
      t.text :prompt
      t.string :data_type
      t.boolean :required
      t.integer :number

      t.timestamps
    end
  end
end
