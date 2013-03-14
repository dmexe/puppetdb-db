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
      expect(node_report.index(:all).key).to eq index_key
    end

    it "should has nodeless_index" do
      expect(node_report.nodeless_index(:all).key).to eq nodeless_index_key
    end
  end

  context "#save" do
    let(:stats) { "stats" }
    subject { ->{ node_report.save } }

    before do
      stub(node_report).stats { stats }
      stub(stats).active? { false }
      stub(stats).failed? { false }
    end

    it "should store in the index" do
      should change{ r_zrange index_key }.from([]).to([[key, tm.to_i.to_f]])
    end

    it "should store in the nodeless index" do
      should change{ r_zrange nodeless_index_key}.from([]).to([[key, tm.to_i.to_f]])
    end

    it "should store a node report" do
      should change{ r_get key }.from(nil).to(json)
    end

    it "should change exists" do
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

    context ".latest" do
      subject { NodeReport.latest(:all, node).map{|i| i.attrs} }
      let(:stats) { { "_stats" => { "success" => 1, "failure" => 1} } }

      it { should eq [attrs2.merge(stats), attrs] }

      context "without node" do
        subject { NodeReport.latest(:all).map{|i| i.attrs} }
        it { should eq [attrs2.merge(stats), attrs] }
      end
    end
  end

  context "(class methods)" do
    subject { NodeReport }

    it ".key" do
      expect(subject.key 'host', 'qwerty').to eq 'db:node:host:reports:qwerty'
    end

    it ".index" do
      expect(subject.index('host', 'all').key).to eq 'db:index:node:host:reports:all'
    end

    it ".exists?" do
      expect{
        node_report.save
      }.to change{
        subject.exists? node, key
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
