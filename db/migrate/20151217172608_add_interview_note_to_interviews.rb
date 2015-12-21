class AddInterviewNoteToInterviews < ActiveRecord::Migration
  def change
    add_column :interviews, :interview_note, :string
  end
end
