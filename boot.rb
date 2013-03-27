require 'rubygems'
require 'bundler'

Bundler.setup(:default, :assets, ENV['RACK_ENV'] || 'development')

require File.expand_path(__FILE__ + "/../lib/app")

module App
  autoload :Home,     App.root.join('lib', 'web', 'home')
  autoload :Api,      App.root.join('lib', 'web', 'api')
  autoload :Reports,  App.root.join('lib', 'web', 'reports')
  autoload :PuppetDB, App.root.join("lib", 'puppetdb')
end

autoload :NodeReport,        App.root.join("lib", "models", "node_report")
autoload :Node,              App.root.join("lib", "models", "node")
autoload :Report,            App.root.join("lib", "models", "report")
autoload :ReportStats,       App.root.join("lib", "models", "report_stats")
autoload :ReportMonthly,     App.root.join("lib", "models", "report_monthly")
autoload :Index,             App.root.join("lib", "models", "index")
autoload :Storage,           App.root.join("lib", "models", "storage")
autoload :ReportProcessing,  App.root.join("lib", "models", "report_processing")
autoload :ReportIndex,       App.root.join("lib", "models", "report_index")

autoload :NodeReportsWorker, App.root.join("lib", "workers", "node_reports_worker")
autoload :ReportWorker,      App.root.join("lib", "workers", "report_worker")
