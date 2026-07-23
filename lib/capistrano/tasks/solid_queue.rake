# frozen_string_literal: true

namespace :solid_queue do
  desc 'Restart SolidQueue'
  task :restart do
    on roles :app do
      execute :sudo, :systemctl, :restart, 'jobapps_solid_queue.service'
    end
  end
end
