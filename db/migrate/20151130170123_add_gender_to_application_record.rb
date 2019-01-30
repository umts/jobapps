class AddGenderToApplicationRecord < ActiveRecord::Migration[4.2]
  def change
    add_column :application_records, :gender, :string
  end
end
