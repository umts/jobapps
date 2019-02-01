class AddDefaultValueToSavedForLaterInApplicationRecords < ActiveRecord::Migration[4.2]
  def change
    change_column :application_records, :saved_for_later, :boolean, default: false
  end
end
