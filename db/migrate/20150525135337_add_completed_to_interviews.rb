class AddCompletedToInterviews < ActiveRecord::Migration[4.2]
  def change
    add_column :interviews, :completed, :boolean
  end
end
