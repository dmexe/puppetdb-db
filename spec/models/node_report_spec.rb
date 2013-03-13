require 'spec_helper'

describe NodeReport do
  let(:tm)          { Time.now.utc - 10 }
  let(:node)        { "example.com" }
  let(:attrs)       { node_report_attrs "certname" => node, "start-time" => tm }
  let(:key)         { "db:node:example.com:reports:abcd" }
  let(:index_key)   { "db:node:example.com:reports" }
  let(:node_report) { NodeReport.new attrs }
  let(:json)        { attrs.to_json }
  subject { node_report }

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
    its(:index_key)        { should eq index_key }
    its(:key)              { should eq key }
    its(:exists?)          { should_not be }

    it "should build from string" do
      expect(NodeReport.new(json).attrs).to eq attrs
    end
  end

  context "#save" do
    subject { ->{ node_report.save; node_report } }

    it "should store the index" do
      should change{ r_get key }.from(nil).to(json)
    end

    it "should store a node report" do
      should change{ r_zrange index_key }.from([]).to([[key, tm.to_i.to_f]])
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
      NodeReport.populate([json, json2]).map{|i| i.save }
    end

    context ".find_keys_by_node" do
      subject { find_keys_by_node }

      it { should eq [key2, key] }

      context "with limit" do
        subject { find_keys_by_node :limit => 1 }
        it { should eq [key2] }
      end

      context "with limit and offset" do
        subject { find_keys_by_node :limit => 1, :offset => 1 }
        it { should eq [key] }
      end

      def find_keys_by_node(options = {})
        NodeReport.find_keys_by_node(node, options)
      end
    end

    context ".find_by_node" do
      subject { find_by_node }

      it { should eq [attrs2, attrs] }

      context "with limit" do
        subject { find_by_node :limit => 1 }
        it { should eq [attrs2] }
      end

      context "with limit and offset" do
        subject { find_by_node :limit => 1, :offset => 1 }
        it { should eq [attrs] }
      end

      def find_by_node(options = {})
        NodeReport.find_by_node(node, options).map{|i| i.attrs }
      end
    end

    context ".find_by_node_with_summary" do
      let(:s_attrs) { report_summary_attrs "hash" => "abcd" }
      let(:summary) { ReportStats.new s_attrs }

      subject { find_by_node_with_summary }
      before { summary.save }

      it { should eq [attrs2, attrs.merge("_summary" => s_attrs)] }

      def find_by_node_with_summary(options = {})
        NodeReport.find_by_node_with_summary(node, options).map{|i| i.attrs }
      end
    end
  end

  context "(class methods)" do
    subject { NodeReport }

    its(:redis){ should be }

    it ".key" do
      expect(subject.key 'host', 'qwerty').to eq 'db:node:host:reports:qwerty'
    end

    it ".index_key" do
      expect(subject.index_key 'host').to eq 'db:node:host:reports'
    end

    it ".exists?" do
      expect{
        node_report.save
      }.to change{
        subject.exists? 'example.com', 'abcd'
      }.from(false).to(true)
    end

    context ".populate" do
      subject { NodeReport.populate [json] }
      its(:size)         { should eq 1 }
      its(:first)        { should be_an_instance_of NodeReport }
      its("first.attrs") { should eq attrs }
    end
  end
end
