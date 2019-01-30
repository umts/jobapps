class AddApplicationTemplateDraftIdToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :application_template_draft_id, :integer
  end
end
