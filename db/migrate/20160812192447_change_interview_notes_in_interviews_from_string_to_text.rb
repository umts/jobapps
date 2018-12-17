class ChangeInterviewNotesInInterviewsFromStringToText < ActiveRecord::Migration[4.2]
  def up
    change_column :interviews, :interview_note, :text
  end

  def down
    change_column :interviews, :interview_note, :string
  end
end
