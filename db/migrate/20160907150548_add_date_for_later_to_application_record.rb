class AddDateForLaterToApplicationRecord < ActiveRecord::Migration[4.2]
  def change
    add_column :application_records, :date_for_later, :date
  end
end
