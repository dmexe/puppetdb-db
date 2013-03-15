require 'spec_helper'

describe Node do
  let(:attrs) { node_attrs }
  let(:node)  { Node.new attrs }
  let(:json)  { attrs.to_json }
  let(:key)   { "nodes:example.com" }
  subject     { node }

  cleanup_redis!

  context "a new instance" do
    it { should be }

    its(:name)              { should eq 'example.com' }
    its(:catalog_timestamp) { should be }
    its(:report_timestamp)  { should be }
    its(:facts_timestamp)   { should be }
    its(:attrs)             { should eq attrs }
    its(:to_json)           { should eq json }
    its(:key)               { should eq key }

    it "should build from string" do
      expect(Node.new(json).attrs).to eq attrs
    end

    it "should has index" do
      expect(node.index(:all).key).to eq "db:index:nodes:all"
    end
  end

  context "#save" do
    subject { ->{ node.save } }

    it "should store in the catalog:index" do
      should change {
        Index['nodes:catalog'].all
      }.from([]).to([key])
    end

    it "should store in the report:index" do
      should change {
        Index['nodes:report'].all
      }.from([]).to([key])
    end

    it "should store in the facts:index" do
      should change {
        Index['nodes:facts'].all
      }.from([]).to([key])
    end

    it "should store a node" do
      should change{ Storage.first key }.from(nil).to(json)
    end
  end

  context "(class methods)" do
    subject { Node }

    it ".key" do
      expect(subject.key 'host').to eq 'nodes:host'
    end

    it ".index" do
      expect(subject.index('host').key).to eq 'db:index:nodes:host'
    end

    context ".create" do
      subject { Node.create json }
      it { should be_an_instance_of Node }
      its(:attrs) { should eq attrs }
    end
  end

  context "(find methods)" do
    let(:attrs2) { attrs.merge("name" => "example2.com") }
    let(:json2) { attrs2.to_json }

    before do
      Node.create attrs
      Node.create attrs2
    end

    context ".latest" do
      subject { Node.latest(:report).map{|i| i.attrs } }
      it { should eq [attrs2, attrs] }
    end

    context ".first" do
      subject { Node.first('example.com').attrs }
      it { should eq attrs }
    end
  end
end
