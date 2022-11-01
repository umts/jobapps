server 'af-transit-app3.admin.umass.edu',
       roles: %w(app db web),
       ssh_options: { forward_agent: false }

set :bundle_env_variables, { 'NOKOGIRI_USE_SYSTEM_LIBRARIES' => 1 }
