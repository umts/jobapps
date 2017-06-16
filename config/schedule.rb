env 'PATH', '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

every :day, at: '12:00am' do
  runner 'ApplicationRecord.move_to_dashboard'
end
