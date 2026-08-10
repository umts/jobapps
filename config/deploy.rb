set :application, 'jobapps'
set :repo_url, 'https://github.com/umts/jobapps.git'
set :branch, :main
set :deploy_to, "/srv/#{fetch :application}"
set :log_level, :info

set :bundle_config, { deployment: true, clean: true }

append :linked_files,
  'config/credentials/production.key'

append :linked_dirs, '.bundle', 'log', 'node_modules', 'storage'

set :passenger_restart_with_sudo, true
set :bundle_version, 4
set :bundle_bins, fetch(:bundle_bins, []).push('bootsnap')

before 'deploy:updated', 'bootsnap:precompile'
after 'deploy:published', 'solid_queue:restart'
