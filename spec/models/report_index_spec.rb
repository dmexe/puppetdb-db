require 'spec_helper'

describe ReportIndex do
  let(:time)   { Time.now }
  let(:node)   { "example.com" }
  let(:digest) { 'sha' }
  let(:attrs)  { { :node => node, :digest => digest, :time => time } }

  cleanup_redis!

  context ".add" do
    let(:report) { Report.new attrs }
    let(:key)    { report.key }

    before do
      expect(report).to be_valid
      ReportIndex.add report
    end

    it "to all node reports index" do
      expect(Index['nodes:example.com:reports:all'].all).to eq [key]
    end

    it "to all reports index" do
      expect(Index['reports:all'].all).to eq [key]
    end

    context "to active node reports index" do
      subject { Index['nodes:example.com:reports:active'].all }
      it { should be_empty }
    end

    context "to active reports index" do
      subject { Index['reports:active'].all }
      it { should be_empty }
    end

    context "when faild report" do
      let(:report) { Report.new attrs.merge :failed => 1 }

      it "active node reports index should be" do
        expect(Index["nodes:example.com:reports:active"].all).to eq [key]
      end

      it "active reports index should be" do
        expect(Index["reports:active"].all).to eq [key]
      end
    end

    context "when success report" do
      let(:report) { Report.new attrs.merge :success => 1 }

      it "active node reports index should be" do
        expect(Index["nodes:example.com:reports:active"].all).to eq [key]
      end

      it "active reports index should be" do
        expect(Index["reports:active"].all).to eq [key]
      end
    end
  end

  context ".find_reports" do
    let(:report)         { Report.create attrs }
    let(:other_report)   { Report.create attrs.merge :node => "other.node", :success => 1 }
    let(:success_report) { Report.create attrs.merge :success => 1, :digest => "successsha" }
    let(:options)        { Hash.new }
    subject { ReportIndex.find_reports(options).map(&:key) }

    before do
      ReportIndex.add report
      ReportIndex.add other_report
      ReportIndex.add success_report
    end

    context "all" do
      it { should eq [other_report.key, success_report.key, report.key] }
    end

    context "all active" do
      let(:options) { { :scope => :active } }
      it { should eq [other_report.key, success_report.key] }
    end

    context "all for node" do
      let(:options) { { node: 'example.com' } }
      it { should eq [success_report.key, report.key] }
    end

    context "all active for node" do
      let(:options) { { node: 'example.com', :scope => :active } }
      it { should eq [success_report.key] }
    end
  end
end
