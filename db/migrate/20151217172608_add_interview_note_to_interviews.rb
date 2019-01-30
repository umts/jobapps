class AddInterviewNoteToInterviews < ActiveRecord::Migration[4.2]
  def change
    add_column :interviews, :interview_note, :string
  end
end
