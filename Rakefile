require 'rspec/core'
require 'rspec/core/rake_task'

task :default => :spec
desc "Run all specs in spec directory"
RSpec::Core::RakeTask.new(:spec)


task :environment do
  require './boot'
end

namespace :cron do
  task :reports => :environment do
    PuppetDB::Client.inst.nodes.each do |n|
      NodeReportsWorker.perform_async(n['name'])
    end
  end
end
