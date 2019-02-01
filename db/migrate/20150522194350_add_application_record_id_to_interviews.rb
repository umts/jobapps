class AddApplicationRecordIdToInterviews < ActiveRecord::Migration[4.2]
  def change
    add_column :interviews, :application_record_id, :integer
  end
end
