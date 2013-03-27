require 'spec_helper'

describe ReportProcessing do
  let(:body) { from_fixture("report.yaml") }
  let(:processing) { described_class.new body }
  subject { processing }

  its(:body)        { should be_an_instance_of(Hash) }
  its(:time)        { should be_an_instance_of(Time) }
  its(:version)     { should be_an_instance_of(Fixnum) }
  its(:host)        { should eq 'master.local'  }
  its(:environment) { should eq 'production' }
  its(:duration)    { should be_an_instance_of(Float) }
  its(:digest)      { should be_an_instance_of(String) }

  context "#resources" do
    subject { processing.resources }

    its(:size)           { should eq 57 }
    its("first.type")    { should eq 'File' }
    its("first.title")   { should eq '/etc/sv/puppetmaster/log/finish' }
    its("first.time")    { should be_an_instance_of(Time) }
    its("first.message") { should eq 'current_value absent, should be present (noop)' }
    its("first.status")  { should eq :skipped }
  end

  context "#stats" do
    subject { processing.stats }
    its(:success) { should eq 1 }
    its(:failed)  { should eq 2 }
    its(:skipped) { should eq 54 }

    its(:to_hash) { should be_key(:success) }
    its(:to_hash) { should be_key(:failed) }
    its(:to_hash) { should be_key(:skipped) }
  end

  context "#to_hash" do
    subject { processing.to_hash }

    %w{ node time version duration digest events stats }.each do |k|
      it { should be_key(k.to_sym) }
    end
  end

  context "#process_delayed!" do
    subject { processing.process_delayed! }
    it { should be }
  end
end

describe ReportProcessing::Resource do
  let(:res) { described_class.new "File", "/etc", Time.now, "message", "success" }
  subject { res }

  context "#to_hash" do
    subject { res.to_hash }
    %w{ type title time message status }.each do |k|
      it { should be_key(k.to_sym) }
    end
  end
end

describe ReportProcessing::Stats do
  let(:stats) { described_class.new 1, 2, 3 }
  subject { stats }

  its(:success) { should eq 1 }
  its(:failed)  { should eq 2 }
  its(:skipped) { should eq 3 }

  context "#to_hash" do
    subject { stats.to_hash }
    %w{ success failed skipped }.each do |k|
      it { should be_key(k.to_sym) }
    end
  end
end
