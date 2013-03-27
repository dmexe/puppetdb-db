require 'spec_helper'

describe ReportWorker do
  let(:key)    { "nodes:master.local:reports:130365c2eba8c4bb50bb4933692fefeab63aff0bd14bcd3ba11b170310c490ae" }
  let(:worker) { ReportWorker.new }

  cleanup_redis!

  context "#perform" do
    let(:report) { from_fixture 'report.yaml' }
    subject {
      worker.perform(report)
      ReportIndex.find_reports.map(&:key)
    }

    it "should store report" do
      expect(subject).to eq [key]
    end

    context "when error in processing" do
      let(:report) { '' }
      it "should raise ReportInvalid" do
        expect {
          subject
        }.to raise_error(ReportWorker::InvalidReport)
      end
    end
  end
end

