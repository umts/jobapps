class DropSiteTexts < ActiveRecord::Migration[5.2]
  def change
    drop_table :site_texts
  end
end
