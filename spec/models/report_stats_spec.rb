require 'spec_helper'

describe ReportStats do
  let(:attrs)          { report_stats_attrs }
  let(:json)           { attrs.to_json }
  let(:report_stats)   { ReportStats.new attrs }
  subject { report_stats }

  context "build from events" do
    let(:events) { events_attrs.to_json }
    subject { ReportStats.build events }

    its(:success) { should eq 1 }
    its(:failure) { should eq 1 }
    its(:skipped) { should eq 0 }
  end

  context "a new instance" do
    its(:skipped)         { should eq 1 }
    its(:success)         { should eq 10 }
    its(:failure)         { should eq 2 }
    its(:to_json)         { should eq json }
    its(:attrs)           { should eq attrs }

    it "should raise error unless attrs" do
      expect {
        ReportStats.new ''
      }.to raise_error(ArgumentError)
    end

    context ".active?" do
      it "should be if has success events" do
        attrs.merge!("success" => 1, "failure" => 0)
        report = ReportStats.new attrs
        expect(report).to be_active
      end
      it "should be if has failed events" do
        attrs.merge!("success" => 0, "failure" => 1)
        report = ReportStats.new attrs
        expect(report).to be_active
      end
      it "should not be if hasnt failed and success events" do
        attrs.merge!("success" => 0, "failure" => 0)
        report = ReportStats.new attrs
        expect(report).to_not be_active
      end
    end

    context ".failed?" do
      it "should be if has failed events" do
        attrs.merge!("success" => 0, "failure" => 1)
        report = ReportStats.new attrs
        expect(report).to be_failed
      end

      it "should not be if hasnt failed events" do
        attrs.merge!("success" => 0, "failure" => 0)
        report = ReportStats.new attrs
        expect(report).to_not be_failed
      end
    end
  end
end
