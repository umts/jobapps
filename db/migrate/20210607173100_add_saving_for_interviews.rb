class AddSavingForInterviews < ActiveRecord::Migration[6.1]
  def change
    add_column :interviews, :saved_for_later, :tinyint, :default => 0
    add_column :interviews, :note_for_later, :text, :default => nil
    add_column :interviews, :date_for_later, :date, :default => nil
  end
end
