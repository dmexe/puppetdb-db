require 'sidekiq'

class ReportWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :puppetdb_reports

  def perform(hash, node_report)
    report       = client.report hash
    report       = Report.new report
    node_report  = NodeReport.new node_report
    report_stats = ReportStats.create report, node_report
    report.save
    node_report.save(:is_active => report_stats.active?)
  end

  private
    def client
      App.puppetdb
    end
end
