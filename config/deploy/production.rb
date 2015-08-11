remote_user = Net::SSH::Config.for('af-transit-app3.admin.umass.edu')[:user] || ENV['USER']
server 'af-transit-app3.admin.umass.edu',
       roles: %w(app db web),
       user: remote_user
set :bundle_env_variables, { 'NOKOGIRI_USE_SYSTEM_LIBRARIES' => 1 }
set :tmp_dir, "/tmp/#{remote_user}"
