class CreateApplicationTemplateDrafts < ActiveRecord::Migration
  def change
    create_table :application_template_drafts do |t|
      t.integer :application_template_id
      t.timestamps
    end
  end
end
