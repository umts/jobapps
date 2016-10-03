every :day, at: '12:00am' do
  runner 'ApplicationRecord.move_to_dashboard'
end
