class AddReviewedToApplicationRecords < ActiveRecord::Migration[4.2]
  def change
    add_column :application_records, :reviewed, :boolean
  end
end
