class CreateApplicationTemplates < ActiveRecord::Migration[4.2]
  def change
    create_table :application_templates do |t|
      t.string :department

      t.timestamps
    end
  end
end
