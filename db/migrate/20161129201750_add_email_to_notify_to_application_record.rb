class AddEmailToNotifyToApplicationRecord < ActiveRecord::Migration[4.2]
  def change
    add_column :application_records, :email_to_notify, :string
  end
end
