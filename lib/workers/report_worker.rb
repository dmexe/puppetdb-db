require 'sidekiq'

class ReportWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :puppetdb_reports

  def perform(body)
    processing = ReportProcessing.new(body)
    report = Report.new processing.to_hash
    report.valid? or raise InvalidReport.new(processing.body.inspect)
    ReportIndex.add report
    report.save
  end

  class InvalidReport < Exception ; end
end
