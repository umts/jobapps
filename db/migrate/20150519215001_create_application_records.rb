class CreateApplicationRecords < ActiveRecord::Migration
  def change
    create_table :application_records do |t|
      t.text :responses

      t.timestamps
    end
  end
end
