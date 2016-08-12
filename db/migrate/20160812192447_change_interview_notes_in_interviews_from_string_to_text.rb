class ChangeInterviewNotesInInterviewsFromStringToText < ActiveRecord::Migration
  def up
    change_column :interviews, :interview_note, :text
  end

  def down
    change_column :interviews, :interview_note, :string
  end
end
