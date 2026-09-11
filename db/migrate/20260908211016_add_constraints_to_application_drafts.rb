# frozen_string_literal: true

class AddConstraintsToApplicationDrafts < ActiveRecord::Migration[8.1]
  def change
    change_column_null :application_drafts, :application_template_id, false
    change_column_null :application_drafts, :user_id, false

    add_foreign_key :application_drafts, :application_templates
    add_foreign_key :application_drafts, :users
  end
end
