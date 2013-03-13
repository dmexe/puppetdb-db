require 'sidekiq'

class ReportWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :puppetdb_reports

  def perform(hash, node_report)
    events       = client.report hash
    node_report  = NodeReport.create node_report, events
    report       = Report.new(events).save
    report
  end

  private
    def client
      App.puppetdb
    end
end
