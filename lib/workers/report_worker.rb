require 'sidekiq'

class ReportWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :puppetdb_reports

  def perform(hash, node_report)
    report      = client.report hash
    report      = Report.new report
    node_report = NodeReport.new node_report
    ReportStats.create report, node_report
    report.save
    node_report.save
  end

  private
    def client
      PuppetDB::Client.inst
    end
end
