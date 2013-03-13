require 'spec_helper'

describe NodeReport do
  let(:tm)               { Time.now.utc - 10 }
  let(:node)             { "example.com" }
  let(:attrs)            { node_report_attrs "certname" => node, "start-time" => tm, "_stats" => {} }
  let(:key)              { "db:node:example.com:reports:abcd" }
  let(:index_key)        { "db:index:node:example.com:reports:all" }
  let(:index_active_key) { "db:index:node:example.com:reports:active" }
  let(:nodeless_index_key) { "db:index:node_reports:all" }
  let(:node_report)      { NodeReport.new attrs }
  let(:json)             { attrs.to_json }
  subject                { node_report }

  cleanup_redis!

  context "a new instance" do
    it { should be }

    its(:hash)             { should eq 'abcd' }
    its(:certname)         { should eq 'example.com' }
    its("start_time.to_i") { should eq tm.to_i }
    its("end_time.to_i")   { should eq tm.to_i + 10 }
    its(:duration)         { should eq 10 }
    its(:attrs)            { should eq attrs }
    its(:to_json)          { should eq attrs.to_json }
    its(:key)              { should eq key }
    its(:exists?)          { should_not be }

    it "should build from string" do
      expect(NodeReport.new(json).attrs).to eq attrs
    end
    it "should has index" do
      expect(node_report.index(:all)).to eq index_key
    end

    it "should has nodeless_index" do
      expect(node_report.nodeless_index(:all)).to eq nodeless_index_key
    end
  end

  context "#save" do
    subject { ->{ node_report.save; node_report } }
    before do
      mock(node_report).stats.mock!.active? { true }
    end

    it "should store in the index" do
      should change{ r_zrange index_key }.from([]).to([[key, tm.to_i.to_f]])
    end

    it "should store in the active index" do
      should change{ r_zrange index_active_key }.from([]).to([[key, tm.to_i.to_f]])
    end

    it "should store in the nodeless index" do
      should change{ r_zrange nodeless_index_key}.from([]).to([[key, tm.to_i.to_f]])
    end

    it "should store a node report" do
      should change{ r_get key }.from(nil).to(json)
    end

    it do
      should change(node_report, :exists?).from(false).to(true)
    end
  end

  context "(find methods)" do
    let(:tm2)    { tm + 10 }
    let(:key2)   { "db:node:example.com:reports:xyz" }
    let(:attrs2) { attrs.merge("hash" => "xyz", "start-time" => tm2.to_s) }
    let(:json2)  { attrs2.to_json }

    before do
      NodeReport.create(json, '[]')
      NodeReport.create(json2, events_attrs)
    end

    context ".latest_keys" do
      subject { latest_keys }

      it { should eq [key2, key] }

      context "with limit" do
        subject { latest_keys :limit => 1 }
        it { should eq [key2] }
      end

      context "with limit and offset" do
        subject { latest_keys :limit => 1, :offset => 1 }
        it { should eq [key] }
      end

      context "active only" do
        subject { latest_keys :active => true }

        it { should eq [key2]}
      end

      context "without node" do
        subject { NodeReport.latest_keys }
        it { should eq [key2, key] }
      end

      def latest_keys(options = {})
        NodeReport.latest_keys(node, options)
      end
    end

    context ".latest" do
      subject { latest }
      let(:stats) { { "_stats" => { "success" => 1, "failure" => 1} } }

      it { should eq [attrs2.merge(stats), attrs] }

      context "with limit" do
        subject { latest :limit => 1 }
        it { should eq [attrs2.merge(stats)] }
      end

      context "with limit and offset" do
        subject { latest :limit => 1, :offset => 1 }
        it { should eq [attrs] }
      end

      context "without node" do
        subject { NodeReport.latest.map{|i| i.attrs} }
        it { should eq [attrs2.merge(stats), attrs] }
      end

      def latest(options = {})
        NodeReport.latest(node, options).map{|i| i.attrs }
      end
    end
  end

  context "(class methods)" do
    subject { NodeReport }

    its(:redis){ should be }

    it ".key" do
      expect(subject.key 'host', 'qwerty').to eq 'db:node:host:reports:qwerty'
    end

    it ".index" do
      expect(subject.index 'host', 'all').to eq 'db:index:node:host:reports:all'
    end

    it ".exists?" do
      expect{
        node_report.save
      }.to change{
        subject.exists? 'example.com', 'abcd'
      }.from(false).to(true)
    end

    context ".create" do
      let(:events) { events_attrs.to_json }
      subject { NodeReport.create json, events }
      it { should be_an_instance_of NodeReport }
      its(:attrs) { should eq attrs.merge("_stats" => {"success" => 1, "failure" => 1}) }
    end
  end
end
