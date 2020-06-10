remote_user = Net::SSH::Config.for('af-transit-app3.admin.umass.edu')[:user] || ENV['USER']
server 'af-transit-app3.admin.umass.edu',
       roles: %w(app db web),
       user: remote_user,
       ssh_options: { forward_agent: false }
set :bundle_env_variables, { 'NOKOGIRI_USE_SYSTEM_LIBRARIES' => 1 }
set :default_env, { 'SECRET_KEY_BASE' => 'NOT_A_REAL_SECRET_AND_THATS_OK' }
