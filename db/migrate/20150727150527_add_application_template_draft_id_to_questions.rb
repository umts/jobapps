class AddApplicationTemplateDraftIdToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :application_template_draft_id, :integer
  end
end
