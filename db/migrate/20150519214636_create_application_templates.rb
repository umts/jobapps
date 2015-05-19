class CreateApplicationTemplates < ActiveRecord::Migration
  def change
    create_table :application_templates do |t|
      t.string :department

      t.timestamps
    end
  end
end
