class AddNotHiringTextToPosition < ActiveRecord::Migration
  def change
    add_column :positions, :not_hiring_text, :string
  end
end
