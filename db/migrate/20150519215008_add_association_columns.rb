class AddAssociationColumns < ActiveRecord::Migration[4.2]
  def change
    add_column :interviews,          :user_id,                 :integer
    add_column :application_records, :user_id,                 :integer
    add_column :response_fields,     :application_template_id, :integer
  end
end
