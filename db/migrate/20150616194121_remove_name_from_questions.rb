class RemoveNameFromQuestions < ActiveRecord::Migration[4.2]
  def change
    remove_column :questions, :name, :string
  end
end
