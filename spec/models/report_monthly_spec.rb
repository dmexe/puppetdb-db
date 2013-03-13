require 'spec_helper'

describe ReportMonthly do
  context ".stats" do
    let(:time) { Time.now.utc }
    subject { ReportMonthly.stats.select{|i| i[1][:requests] > 0 } }

    cleanup_redis!

    before do
      3.times do |n|
        tm = time - (n * 60 * 60 * 24)
        hash = "hash#{n}"
        node = "node#{n % 2}"
        attrs = {
          "start-time" => tm.to_s,
          "end-time"   => (tm + 10).to_s,
          "hash"       => hash,
          "certname"   => node
        }
        NodeReport.create(attrs, events_attrs)
      end
    end

    its(:size) { should eq 3 }

    its(:last) do
      hash = { :success => 1, :failure => 1, :skipped => 0, :duration => 10, :requests => 1 }
      tm = Time.utc(time.year, time.month, time.day)
      should eq [tm, hash]
    end

    context "with node" do
      subject { ReportMonthly.stats(node: "node0").select{|i| i[1][:requests] > 0 } }
      its(:size) { should eq 2 }
    end
  end
end
