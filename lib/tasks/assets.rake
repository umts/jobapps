# frozen_string_literal: true

namespace :assets do
  task :install do
    raise 'Command npm install failed, ensure npm is installed' unless system('npm install')
  end
end

Rake::Task["assets:precompile"].enhance(["assets:install"])
