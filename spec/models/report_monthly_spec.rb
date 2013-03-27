require 'spec_helper'

describe ReportMonthly do
  context ".stats" do
    let(:time) { Time.now.utc }
    subject { ReportMonthly.stats.select{|i| i[1][:requests] > 0 } }

    cleanup_redis!

    before do
      3.times do |n|
        tm = time - (n * 60 * 60 * 24)
        digest = "hash#{n}"
        node = "node#{n % 2}"
        attrs = {
          :duration => (n + 1) * 10,
          :digest   => digest,
          :node     => node,
          :time     => tm,
          :success  => n + 1,
          :failed   => 5 - n,
          :skipped  => 3 - n
        }
        report = Report.create(attrs)
        ReportIndex.add report
      end
    end

    its(:size) { should eq 3 }

    its(:last) do
      hash = { :success => 1, :failed => 5, :skipped => 3, :duration => 10.0, :requests => 1 }
      tm = Time.utc(time.year, time.month, time.day)
      should eq [tm, hash]
    end

    context "with node" do
      subject { ReportMonthly.stats(node: "node0").select{|i| i[1][:requests] > 0 } }
      its(:size) { should eq 2 }
    end
  end
end
