class AddCompletedToInterviews < ActiveRecord::Migration
  def change
    add_column :interviews, :completed, :boolean
  end
end
