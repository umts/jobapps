class AddGenderToApplicationRecord < ActiveRecord::Migration
  def change
    add_column :application_records, :gender, :string
  end
end
