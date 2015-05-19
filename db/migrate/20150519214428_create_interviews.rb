class CreateInterviews < ActiveRecord::Migration
  def change
    create_table :interviews do |t|
      t.boolean :hired
      t.datetime :scheduled

      t.timestamps
    end
  end
end
