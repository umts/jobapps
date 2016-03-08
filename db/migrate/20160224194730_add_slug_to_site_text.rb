class AddSlugToSiteText < ActiveRecord::Migration
  def change
    add_column :site_texts, :slug, :string
  end
end
