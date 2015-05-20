class ChangeResponseFieldsToQuestions < ActiveRecord::Migration
  def change
    rename_table :response_fields, :questions
  end
end
