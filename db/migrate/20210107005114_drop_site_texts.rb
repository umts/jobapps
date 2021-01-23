class DropSiteTexts < ActiveRecord::Migration[5.2]
  def change
    drop_table :site_texts do |t|
      t.string 'name'
      t.text 'text'
      t.string 'slug'
      t.timestamps
    end
  end
end
