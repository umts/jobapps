# frozen_string_literal: true

# TODO: Remove when either jsbundling-rails or cssbundling-rails is set up.

namespace :assets do
  task install: :environment do
    raise 'Command npm install failed, ensure npm is installed' unless system('npm install')
  end
end

Rake::Task['assets:precompile'].enhance(['assets:install'])
