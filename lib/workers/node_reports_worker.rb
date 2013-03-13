require 'sidekiq'

class NodeReportsWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :puppetdb_node_reports

  def perform(node_name)
    reports = client.reports(node_name)
    reports.map!{|i| NodeReport.new i }
    not_exists = reports.select do |report|
      not report.exists?
    end
    not_exists.each do |report|
      ReportWorker.perform_async(report.hash, report.attrs)
    end
  end

  private
    def client
      App.puppetdb
    end
end
