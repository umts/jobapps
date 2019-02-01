class CreateSiteTexts < ActiveRecord::Migration[4.2]
  def change
    create_table :site_texts do |t|
      t.string :name
      t.text :text

      t.timestamps
    end
  end
end
