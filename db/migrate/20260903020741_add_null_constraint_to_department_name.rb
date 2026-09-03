# frozen_string_literal: true

class AddNullConstraintToDepartmentName < ActiveRecord::Migration[8.1]
  def change
   change_column_null :departments, :name, false
  end
end
