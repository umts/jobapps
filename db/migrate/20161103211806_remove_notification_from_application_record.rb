class RemoveNotificationFromApplicationRecord < ActiveRecord::Migration
  def change
    remove_column :application_records, :notification, :boolean
  end
end
