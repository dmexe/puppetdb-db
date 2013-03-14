require 'spec_helper'

describe Report do
  let(:tm)        { (Time.now - 10).utc }
  let(:attrs)     { report_attrs("timestamp" => tm) }
  let(:key)       { "reports:abcd" }
  let(:index_key) { "db:index:reports" }
  let(:json)      { [attrs].to_json }
  let(:report)    { Report.new [attrs] }
  subject { report }

  cleanup_redis!

  context "a new instance" do
    its(:to_json)         { should eq json }
    its("timestamp.to_i") { should eq tm.to_i }
    its(:key)             { should eq key }
    its("index.key")      { should eq index_key }
    its(:hash)            { should eq "abcd" }
    its(:events)          { should eq [attrs] }

    it "should get hash from options" do
      expect(Report.new([attrs], :hash => "xyz").hash).to eq "xyz"
    end

    it "should raise error unless hash" do
      expect {
        Report.new [attrs.merge("report" => nil)]
      }.to raise_error(ArgumentError)
    end

    it "should build from string" do
      expect(Report.new(json).events).to eq [attrs]
    end
  end

  context "#save" do
    subject { ->{ report.save } }

    it "should store the index" do
      should change{ Index['reports'].all }.from([]).to([key])
    end

    it "should store a report" do
      should change{ Storage.first key }.from(nil).to(json)
    end
  end

  context "(class methods)" do
    subject { Report }

    its("index.key") { should eq 'db:index:reports' }

    it ".key" do
      expect(subject.key "xzy").to eq 'reports:xzy'
    end
  end

  context "(find methods)" do
    let(:tm2) { tm + 10 }
    let(:attrs2) {
      attrs.merge("report" => "zxy", "timestamp" => tm2.to_s)
    }

    before do
      [attrs,attrs2].each{|i| Report.create([i]) }
    end

    context ".get" do
      subject { Report.get(["zxy", 'abcd']).map{|i| i.events } }
      it { should eq [[attrs2],[attrs]] }
    end

    context ".first" do
      subject { Report.first("zxy").events }
      it { should eq [attrs2] }
    end
  end
end
