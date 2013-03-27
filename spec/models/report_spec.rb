require 'spec_helper'

describe Report do
  let(:time) { Time.now }
  let(:attrs) { {
    :node     => "example.com",
    :time     => time,
    :version  => 123,
    :duration => 1.2,
    :digest   => 'sha',
    :success  => 1,
    :failed   => 2,
    :skipped  => 3,
    :events   => [],
  } }
  let(:report)    { Report.new attrs }
  subject { report }

  cleanup_redis!

  context "a new instance" do
    it { should be_valid }

    its(:node)     { should eq 'example.com' }
    its(:time)     { should eq time }
    its(:version)  { should eq 123 }
    its(:duration) { should eq 1.2 }
    its(:digest)   { should eq 'sha' }
    its(:success)  { should eq 1 }
    its(:failed)   { should eq 2 }
    its(:skipped)  { should eq 3 }
    its(:events)   { should eq [] }

    its(:to_json)  { should be }

    it "should build from string" do
      expect(Report.new(attrs.to_json)).to be
    end

    context "#to_hash" do
      subject { report.to_hash }
      %w{ node time version duration digest success failed skipped events }.each do |k|
        it { should be_key(k.to_sym) }
      end
    end

    it "#success?" do
      report.success = 1
      expect(report).to be_success
      report.success = 0
      expect(report).to_not be_success
    end

    it "#failed?" do
      report.failed = 1
      expect(report).to be_failed
      report.failed = 0
      expect(report).to_not be_failed
    end

    context "validation" do
      context "#node" do
        before do
          report.node = ''
        end
        it { should_not be_valid }
      end
      context "#digest" do
        before do
          report.digest = ''
        end
        it { should_not be_valid }
      end
      context "#time" do
        before do
          report.time = ''
        end
        it { should_not be_valid }
      end
    end
  end

  context "#save" do
    let(:json) { report.to_json }
    let(:key) { report.key }
    subject { ->{ report.save } }

    it "should store a report" do
      should change{ Storage.first key }.from(nil).to(json)
    end
  end

  context "(class methods)" do
    subject { Report }

    it ".key" do
      expect(subject.key "node", 'sha').to eq 'nodes:node:reports:sha'
    end

    context ".get" do
      subject { Report.get [report.key] }
      before do
        Report.create attrs
      end

      its(:size)       { should eq 1 }
      its(:first)      { should be_an_instance_of(Report) }
      its("first.key") { should eq report.key }
    end
  end
end
