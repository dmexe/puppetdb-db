require 'spec_helper'

describe Index do
  let(:index) { Index.new 'foo' }
  subject { index }

  cleanup_redis!

  context "a new instance" do
    its(:key) { should eq 'db:index:foo' }
  end

  context "#add" do
    let(:value) { 'value' }
    subject { -> { index.add(1, value) } }

    it "store in the index" do
      should change{
        index.redis.zrange index.key, 0, -1, :withscores => true
      }.from([]).to( [[value, 1.0]] )
    end

    it "change content exists" do
      should change {
        index.exists? value
      }.from(false).to(true)
    end
  end

  context "#all" do
    let(:tm1) { Time.new - 1_100 }
    let(:tm2) { Time.new - 1_200 }
    let(:value1) { 'value1' }
    let(:value2) { 'value2' }
    let(:params) { Hash.new }

    subject { index.all params }

    before do
      index.add tm1, value1
      index.add tm2, value2
    end

    it { should eq [value1, value2] }

    context "with options" do
      context ":from" do
        let(:params) { { from: tm1 } }
        it { should eq [value1] }
      end

      context ":to" do
        let(:params) { { to: tm2 } }
        it { should eq [value2] }
      end

      context ":limit" do
        let(:params) { { limit: 1 } }
        it { should eq [value1] }
      end

      context ":limit and :offset" do
        let(:params) { { limit: 1, offset: 1 } }
        it { should eq [value2] }
      end

      context ":order => :asc" do
        let(:params) { { order: :asc } }
        it { should eq [value2, value1] }
      end
    end
  end

  context ".[]" do
    subject { Index[:foo] }
    it{ should be_an_instance_of Index }
    its(:object_id){ should eq Index[:foo].object_id }
  end
end
