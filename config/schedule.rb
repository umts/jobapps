env 'PATH', '/opt/ruby/bin:/usr/sbin:/usr/bin:/sbin:/bin'
env 'SECRET_KEY_BASE', 'DOESNOTMATTER'

every :day, at: '12:00am' do
  runner 'ApplicationSubmission.move_to_dashboard'
end
