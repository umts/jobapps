class CreateApplicationRecords < ActiveRecord::Migration[4.2]
  def change
    create_table :application_records do |t|
      t.text :responses

      t.timestamps
    end
  end
end
