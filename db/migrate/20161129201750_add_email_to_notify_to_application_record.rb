class AddEmailToNotifyToApplicationRecord < ActiveRecord::Migration
  def change
    add_column :application_records, :email_to_notify, :string
  end
end
