class CreateSiteTexts < ActiveRecord::Migration
  def change
    create_table :site_texts do |t|
      t.string :name
      t.text :text

      t.timestamps
    end
  end
end
