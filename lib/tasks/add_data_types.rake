namespace :application_records do
  task add_data_types: :environment do
    ApplicationRecord.find_each(&:add_data_types)
  end
end
