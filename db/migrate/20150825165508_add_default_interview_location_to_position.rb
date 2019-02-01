class AddDefaultInterviewLocationToPosition < ActiveRecord::Migration[4.2]
  def change
    add_column :positions, :default_interview_location, :string
  end
end
