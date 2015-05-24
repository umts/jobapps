class AddApplicationRecordIdToInterviews < ActiveRecord::Migration
  def change
    add_column :interviews, :application_record_id, :integer
  end
end
