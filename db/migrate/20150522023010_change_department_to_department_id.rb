class ChangeDepartmentToDepartmentId < ActiveRecord::Migration[4.2]
  def change
    rename_column :application_templates, :department, :department_id
    change_column :application_templates, :department_id, :integer 

    add_column :application_records, :department_id, :integer
  end
end
