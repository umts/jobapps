class AddNotHiringTextToPosition < ActiveRecord::Migration[4.2]
  def change
    add_column :positions, :not_hiring_text, :string
  end
end
