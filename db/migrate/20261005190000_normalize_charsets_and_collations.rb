# frozen_string_literal: true

class NormalizeCharsetsAndCollations < ActiveRecord::Migration[8.1]
  def change
    database = ActiveRecord::Base.connection
    execute "ALTER DATABASE `#{database.current_database}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;"
    database.tables.each do |table|
      execute "ALTER TABLE `#{table}` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_520_ci;"
    end
  end
end
