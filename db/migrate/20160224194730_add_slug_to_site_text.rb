class AddSlugToSiteText < ActiveRecord::Migration[4.2]
  def change
    add_column :site_texts, :slug, :string
  end
end
