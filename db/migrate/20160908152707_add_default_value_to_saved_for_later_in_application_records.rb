class AddDefaultValueToSavedForLaterInApplicationRecords < ActiveRecord::Migration
  def change
    change_column :application_records, :saved_for_later, :boolean, default: false
  end
end
