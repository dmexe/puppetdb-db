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
  its(:hash)        { should be_an_instance_of(String) }

  context "#resources" do
    let(:resources) { processing.resources }
    subject { resources }

    its(:size)           { should eq 57 }
    its("first.type")    { should eq 'File' }
    its("first.title")   { should eq '/etc/sv/puppetmaster/log/finish' }
    its("first.time")    { should be_an_instance_of(Time) }
    its("first.message") { should eq 'current_value absent, should be present (noop)' }
    its("first.status")  { should eq :skipped }

    context "statuses" do
      subject { resources.group_by{|i| i.status }.map{|k,v| [k,v.size] }.sort }
      it { should eq [[:changed, 1], [:failed, 2], [:skipped, 54]] }
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

  its(:to_json) { should be_an_instance_of(String) }
end
