# frozen_string_literal: true

namespace :bootsnap do
  desc 'Precompile bootsnap'
  task :precompile do
    on roles :app do
      within release_path do
        execute :bootsnap, :precompile, '--gemfile', 'config/', 'app/', 'lib/'
      end
    end
  end
end
