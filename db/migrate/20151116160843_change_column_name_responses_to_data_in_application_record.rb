class ChangeColumnNameResponsesToDataInApplicationRecord < ActiveRecord::Migration
  def change
    rename_column :application_records, :responses, :data
  end
end
