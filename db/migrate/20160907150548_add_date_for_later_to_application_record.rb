class AddDateForLaterToApplicationRecord < ActiveRecord::Migration
  def change
    add_column :application_records, :date_for_later, :date
  end
end
