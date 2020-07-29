# config valid only for current version of Capistrano
lock  '~> 3.14.1'

set :application, 'jobapps'
set :repo_url, 'https://github.com/umts/jobapps.git'
set :branch, :master
set :deploy_to, "/srv/#{fetch :application}"
set :log_level, :info

set :whenever_command, [:sudo, :bundle, :exec, :whenever]

append :linked_files,
  'config/application.yml',
  'config/database.yml'

append :linked_dirs, '.bundle', 'log'
