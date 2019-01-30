class AddEthnicityToApplicationRecord < ActiveRecord::Migration[4.2]
  def change
    add_column :application_records, :ethnicity, :string
  end
end
