%w(setup deploy bundler rails passenger).each { |r| require "capistrano/#{r}" }
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
