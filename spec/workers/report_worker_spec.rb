require 'spec_helper'

describe ReportWorker do
  let(:hash)   { '38ff2aef3ffb7800fe85b322280ade2b867c8d27' }
  let(:attrs)  { node_report_attrs }
  let(:worker) { ReportWorker.new }

  cleanup_redis!

  context "#perform" do
    subject { -> { worker.perform(hash, attrs) } }
    before  do
      mock_puppetdb_events_request hash
      Timecop.freeze(Time.utc(2012, 11, 1))
    end

    it "should create reports" do
      should change(Report, :find_keys).from([]).to(["db:reports:#{hash}"])
    end

    it "should create report summary" do
      should change{
        f = ReportStats.find(hash).first
        f.hash if f
      }.from(nil).to(hash)
    end
  end
end

