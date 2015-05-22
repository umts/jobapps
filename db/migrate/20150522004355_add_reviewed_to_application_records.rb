class AddReviewedToApplicationRecords < ActiveRecord::Migration
  def change
    add_column :application_records, :reviewed, :boolean
  end
end
