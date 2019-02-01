class CreateEmailTemplates < ActiveRecord::Migration[4.2]
  def change
    create_table :email_templates do |t|
      t.text :text

      t.timestamps
    end
  end
end
