# Example invocation: RAILS_ENV=production bundle exec rake referral_method_and_hire_stats:bus ~/export.csv
# will generate a CSV file at ~/export.csv
REFERRAL_METHODS = [
  'Advertisement inside bus', 'Bus destination sign',
  'Poster in bus stop shelter', 'Poster in Campus Center',
  'Resource fair / orientation', 'Referred by employee'
]

namespace :referral_method_and_hire_stats do
  task bus: :environment do
    CSV.open(ARGV[1], 'wb') do |csv|
      department = Department.find_by(name: 'Bus')
      position = department.positions.find_by(name: 'Operator')
      records = position.application_records.includes(:interview)
      # headers
      csv << %w(date applicant referral_method interviewed hired)
      records.newest_first.each do |ar|
        row = []
        row << ar.created_at.to_date.to_s
        row << ar.user.full_name
        row << REFERRAL_METHODS.find do |rm|
          ar.data.find do |prompt, response, _data_type, _id|
            prompt == rm && response == 'Yes'
          end.try(:first) || 'None given' # Grab the response
        end
        row << ar.interview.present?
        row << (ar.interview.present? && ar.interview.hired?)
        csv << row
      end
    end
  end
end
