set :application, 'jobapps'
set :repo_url, 'https://github.com/umts/jobapps.git'
set :branch, :main
set :deploy_to, "/srv/#{fetch :application}"
set :log_level, :info

set :bundle_config, { deployment: true, clean: true }
set :whenever_command, [:sudo, :bundle, :exec, :whenever]

append :linked_files,
  'config/application.yml',
  'config/database.yml',
  'config/credentials/production.key'

append :linked_dirs, '.bundle', 'log', 'node_modules', 'storage'

set :passenger_restart_with_sudo, true
