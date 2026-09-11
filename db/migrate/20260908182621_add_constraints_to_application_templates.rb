# frozen_string_literal: true

class AddConstraintsToApplicationTemplates < ActiveRecord::Migration[8.1]
  def change
    change_column_null :application_templates, :position_id, false
    change_column_null :application_templates, :active, false

    add_foreign_key :application_templates, :positions
  end
end
