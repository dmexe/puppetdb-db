require 'spec_helper'

describe MonthlyReport do
  context ".stats" do
    let(:time) { Time.now.utc }
    subject { MonthlyReport.stats.select{|i| i[1][:requests] > 0 } }

    cleanup_redis!

    before do
      3.times do |n|
        tm = time - (n * 60 * 60 * 24)
        hash = "hash#{n}"
        node = "node#{n % 2}"
        node_report = NodeReport.new(node_report_attrs "start-time" => tm, "hash" => hash, "certname" => node).save
        report      = Report.new([report_attrs("report" => hash)]).save
        summary     = ReportSummary.new(report_summary_attrs "hash" => hash, "timestamp" => tm).save
      end
    end

    its(:size) { should eq 3 }

    its(:last) do
      hash = { :success => 10, :failed => 2, :skipped => 1, :duration => 10, :requests => 1 }
      tm = Time.utc(time.year, time.month, time.day)
      should eq [tm, hash]
    end

    context "with node" do
      subject { MonthlyReport.stats(node: "node0").select{|i| i[1][:requests] > 0 } }
      its(:size) { should eq 2 }
    end
  end
end
