require 'spec_helper'

describe Storage do
  let(:key)     { 'key' }
  let(:value)   { 'value' }
  let(:storage) { Storage.new key }
  subject { storage }

  cleanup_redis!

  context "a new instance" do
    its(:key){  should eq "db:storage:#{key}"}
  end

  context "#add" do
    subject { -> { storage.add value } }

    it "should store value" do
      should change {
        App.redis.get "db:storage:#{key}"
      }.from(nil).to(value)
    end
  end

  context ".first" do
    subject { Storage.first key }
    before { Storage[key].add value }
    it { should eq value }
  end

  context ".get" do
    subject { Storage.get [key] }
    before { Storage[key].add value }

    it { should eq [value] }

    context "a empty keys" do
      subject { Storage.get [] }
      it { should eq [] }
    end
  end

  context ".[]" do
    subject { Storage[key] }
    it { should be_an_instance_of(Storage) }
  end
end
