require 'spec_helper'

describe ReportStats do
  let(:tm)             { (Time.now - 10).utc }
  let(:attrs)          { report_summary_attrs "timestamp" => tm }
  let(:key)            { "db:reports:abcd:stats" }
  let(:json)           { attrs.to_json }
  let(:report_summary) { ReportStats.new attrs }
  subject { report_summary }

  cleanup_redis!

  context "a new instance" do
    its(:skipped)         { should eq 1 }
    its(:success)         { should eq 10 }
    its(:failure)         { should eq 2 }
    its(:duration)        { should eq 10 }
    its("timestamp.to_i") { should eq tm.to_i }
    its(:to_json)         { should eq json }
    its(:hash)            { should eq "abcd" }
    its(:key)             { should eq key }
    its(:attrs)           { should eq attrs }
    its(:exists?)         { should eq false }

    it "should get hash from options" do
      expect(ReportStats.new(attrs, :hash => "xyz").hash).to eq "xyz"
    end

    it "should raise error unless hash" do
      expect {
        ReportStats.new attrs.merge("hash" => nil)
      }.to raise_error(ArgumentError)
    end

    it "should build from string" do
      expect(ReportStats.new(json).attrs).to eq attrs
    end

    context ".active?" do
      it "should be if has success reports" do
        attrs.merge!("success" => 1, "failure" => 0)
        report = ReportStats.new attrs
        expect(report).to be_active
      end
      it "should be if has failed reports" do
        attrs.merge!("success" => 0, "failure" => 1)
        report = ReportStats.new attrs
        expect(report).to be_active
      end
      it "should not be if no failed and success reports" do
        attrs.merge!("success" => 0, "failure" => 0)
        report = ReportStats.new attrs
        expect(report).to_not be_active
      end
    end
  end

  context "#save" do
    subject { ->{ report_summary.save; report_summary } }

    it "should store a summary report" do
      should change{ r_get key }.from(nil).to(json)
    end

    it do
      should change(report_summary, :exists?).from(false).to(true)
    end
  end

  context "(class methods)" do
    subject { ReportStats }

    its(:redis)     { should be }

    it ".key" do
      expect(subject.key "xzy").to eq 'db:reports:xzy:stats'
    end

    context ".create" do
      let(:report) {
        Report.new(
          [{"status" => "success"},
           {"status" => "success"},
           {"status" => "success"},
           {"status" => "skipped"},
           {"status" => "skipped"},
           {"status" => "failure"}],
          :hash => 'abcd')
      }
      let(:node_report) { Object.new }
      subject { ReportStats.create(report, node_report) }

      before do
        mock(node_report).duration{ 12 }
        mock(node_report).start_time{ tm }
      end

      context "create a report summary with" do
        its(:success)   { should eq 3 }
        its(:skipped)   { should eq 2 }
        its(:failure)   { should eq 1 }
        its(:duration)  { should eq 12 }
        its(:hash)      { should eq 'abcd' }
        its("timestamp.to_i") { should eq tm.to_i }
        it { should be_exists }
      end
    end
  end

  context "(find methods)" do
    let(:tm2)    { (tm + 5).utc }
    let(:attrs2) { attrs.merge("hash" => "zxy", "timestamp" => tm2.to_i) }

    before do
      ReportStats.new(attrs).save
      ReportStats.new(attrs2).save
    end

    context ".find" do
      subject { ReportStats.find(%w{ abcd zxy }).map{|i| i.attrs } }
      it { should eq [attrs, attrs2] }
    end
  end
end
