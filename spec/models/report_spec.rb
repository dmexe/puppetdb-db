require 'spec_helper'

describe Report do
  let(:tm)        { (Time.now - 10).utc }
  let(:attrs)     { report_attrs("timestamp" => tm) }
  let(:key)       { "db:reports:abcd" }
  let(:index_key) { "db:index:reports" }
  let(:json)      { [attrs].to_json }
  let(:report)    { Report.new [attrs] }
  subject { report }

  cleanup_redis!

  context "a new instance" do
    its(:to_json)         { should eq json }
    its("timestamp.to_i") { should eq tm.to_i }
    its(:key)             { should eq key }
    its(:index_key)       { should eq index_key }
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
    subject { ->{ report.save; report } }

    it "should store the index" do
      should change{ r_get key }.from(nil).to(json)
    end

    it "should store a report" do
      should change{ r_zrange index_key }.from([]).to([[key, tm.to_i.to_f]])
    end
  end

  context "(class methods)" do
    subject { Report }

    its(:index_key) { should eq 'db:index:reports' }
    its(:redis)     { should be }

    it ".key" do
      expect(subject.key "xzy").to eq 'db:reports:xzy'
    end

    context ".populate" do
      subject { Report.populate json }
      it { should be_an_instance_of Report }
      its(:events) { should eq [attrs] }
    end
  end

  context "(find methods)" do
    let(:tm2) { tm + 10 }
    let(:attrs2) {
      attrs.merge("report" => "zxy", "timestamp" => tm2.to_s)
    }

    before do
      [attrs,attrs2].each{|i| Report.new([i]).save }
    end

    context ".find_keys" do
      subject { find_keys }

      it { should eq ["db:reports:zxy", "db:reports:abcd"] }

      context "with from" do
        subject { find_keys tm2 }
        it { should eq ['db:reports:zxy'] }
      end

      def find_keys(from = nil)
        Report.find_keys from
      end
    end

    context ".find" do
      subject { Report.find(["zxy", 'abcd']).map{|i| i.events } }
      it { should eq [[attrs2],[attrs]] }
    end

    context ".first" do
      subject { Report.first("zxy").events }
      it { should eq [attrs2] }
    end
  end
end
