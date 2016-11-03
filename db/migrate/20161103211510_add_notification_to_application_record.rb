class AddNotificationToApplicationRecord < ActiveRecord::Migration
  def change
    add_column :application_records, :notification, :boolean
  end
end
