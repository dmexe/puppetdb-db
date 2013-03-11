require 'spec_helper'

describe NodeReportsWorker do
  let(:host) { 'example.com' }
  let(:worker) { NodeReportsWorker.new }
  subject { worker }

  cleanup_redis!

  context "#perform" do
    subject { -> { worker.perform host } }
    before { mock_puppetdb_reports_request host }

    it "should send jobs to ReportWorker" do
      should change(ReportWorker.jobs, :size).from(0).to(2)
    end
  end

end
