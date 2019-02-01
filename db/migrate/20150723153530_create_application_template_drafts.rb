class CreateApplicationTemplateDrafts < ActiveRecord::Migration[4.2]
  def change
    create_table :application_template_drafts do |t|
      t.integer :application_template_id
      t.timestamps
    end
  end
end
