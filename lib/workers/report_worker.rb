require 'sidekiq'

class ReportWorker
  include Sidekiq::Worker

  sidekiq_options :queue => :puppetdb_reports

  def perform(body)
    attributes = ReportProcessing.new(body).to_hash
    report = Report.new attributes
    report.valid? or raise InvalidReport.new(body.inspect)
    ReportIndex.add report
    report.save
  end

  class InvalidReport < Exception ; end
end
