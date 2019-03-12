env 'PATH', '/opt/ruby/bin:/usr/sbin:/usr/bin:/sbin:/bin'

every :day, at: '12:00am' do
  runner 'ApplicationSubmission.move_to_dashboard'
end
