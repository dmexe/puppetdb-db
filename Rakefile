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
