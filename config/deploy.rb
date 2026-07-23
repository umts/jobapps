set :application, 'jobapps'
set :repo_url, 'https://github.com/umts/jobapps.git'
set :branch, :main
set :deploy_to, "/srv/#{fetch :application}"
set :log_level, :info

set :bundle_config, { deployment: true, clean: true }

append :linked_files,
  'config/application.yml',
  'config/credentials/production.key'

append :linked_dirs, '.bundle', 'log', 'node_modules', 'storage'

set :passenger_restart_with_sudo, true
set :bundle_version, 4

after 'deploy:published', 'solid_queue:restart'
