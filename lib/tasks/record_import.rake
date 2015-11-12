require 'csv'

namespace :application_records do
  task :import, [:csv_file] => :environment do |_, args|
    CSV.foreach(args[:csv_file], headers: true, col_sep: ',') do |row|
      record = ApplicationRecord.find(row.fetch 'Record Number')
      record.add_response_data(row.fetch('Prompt'), row.fetch('Response'))
    end
  end
end
