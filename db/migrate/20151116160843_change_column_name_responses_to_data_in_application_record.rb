class ChangeColumnNameResponsesToDataInApplicationRecord < ActiveRecord::Migration[4.2]
  def change
    rename_column :application_records, :responses, :data
  end
end
