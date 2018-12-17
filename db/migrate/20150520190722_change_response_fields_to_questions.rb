class ChangeResponseFieldsToQuestions < ActiveRecord::Migration[4.2]
  def change
    rename_table :response_fields, :questions
  end
end
