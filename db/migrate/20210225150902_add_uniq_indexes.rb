class AddUniqIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :application_drafts, [:user_id, :application_template_id], unique: true
    add_index :application_templates, :position_id, unique: true
    add_index :departments, :name, unique: true
    add_index :questions, [:application_template_id, :number], unique: true
    add_index :questions, [:application_draft_id, :number], unique: true
    add_index :subscriptions, [:position_id, :email], unique: true
    add_index :users, :spire, unique: true
  end
end
