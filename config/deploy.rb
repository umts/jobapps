# config valid only for current version of Capistrano
lock  '~> 3.14'

set :application, 'jobapps'
set :repo_url, 'https://github.com/umts/jobapps.git'
set :branch, :master
set :deploy_to, "/srv/#{fetch :application}"
set :log_level, :info

set :whenever_command, [:sudo, :bundle, :exec, :whenever]

append :linked_files,
  'config/application.yml',
  'config/database.yml',
  'config/credentials/production.yml.enc'

append :linked_dirs, '.bundle', 'log', 'node_modules'

set :passenger_restart_with_sudo, true
