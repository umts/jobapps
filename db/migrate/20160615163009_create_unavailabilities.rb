class CreateUnavailabilities < ActiveRecord::Migration
  def change
    create_table :unavailabilities do |t|
      t.string :sunday
      t.string :monday
      t.string :tuesday
      t.string :wednesday
      t.string :thursday
      t.string :friday
      t.string :saturday
      t.integer :application_record_id

      t.timestamps null: false
    end
  end
end
