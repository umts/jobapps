class AddDefaultInterviewLocationToPosition < ActiveRecord::Migration
  def change
    add_column :positions, :default_interview_location, :string
  end
end
