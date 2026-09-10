# frozen_string_literal: true

class AddConstraintsToQuestions < ActiveRecord::Migration[8.1]
  def change
    change_column_null :questions, :data_type, false
    change_column_null :questions, :prompt, false
    change_column_null :questions, :number, false
    change_column_null :questions, :required, false

    add_foreign_key :questions, :application_templates
    add_foreign_key :questions, :application_drafts
  end
end
