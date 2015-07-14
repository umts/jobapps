# config valid only for current version of Capistrano
lock '3.4.0'

set :application, :jobapps
set :repo_url, 'git@github.com:umts/jobapps.git'
set :branch, :cap
set :deploy_to, "/srv/#{fetch :application}"
set :log_level, :info
set :scm, :git
set :keep_releases, 5

set :linked_files, fetch(:linked_files, []).push(
  'config/application.yml',
  'config/database.yml'
)

set :linked_dirs, fetch(:linked_dirs, []).push(
  'log'
)
