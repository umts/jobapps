class AddEthnicityToApplicationRecord < ActiveRecord::Migration
  def change
    add_column :application_records, :ethnicity, :string
  end
end
