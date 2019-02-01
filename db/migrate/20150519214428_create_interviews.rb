class CreateInterviews < ActiveRecord::Migration[4.2]
  def change
    create_table :interviews do |t|
      t.boolean :hired
      t.datetime :scheduled

      t.timestamps
    end
  end
end
