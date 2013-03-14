require 'json'
require 'time'

class NodeReport
  class << self
    def create(json, events)
      stats = ReportStats.build(events)
      NodeReport.new(json, :stats => stats.attrs).save
    end

    def latest(*args)
      options   = args.pop if args.last.is_a?(Hash)
      options ||= {}
      scope     = args.shift || :all
      node_name = args.shift
      keys      = index(node_name, scope).all(*(args << options))
      reports   = Storage.get keys
      reports.map!{|i| NodeReport.new i }
    end

    def key(node_name, hash)
      "node:#{node_name}:reports:#{hash}"
    end

    def index(node_name, scope)
      if node_name == nil
        Index["node_reports:#{scope}"]
      else
        Index["node:#{node_name}:reports:#{scope}"]
      end
    end

    def exists?(node_name, key)
      index(node_name, :all).exists? key
    end
  end

  attr_reader :attrs

  def initialize(attrs, options = {})
    attrs = JSON.parse(attrs) if attrs.is_a?(String)
    @attrs = attrs
    @attrs.merge!("_stats" => options[:stats]) if options[:stats]
  end

  def hash
    @attrs["hash"]
  end

  def certname
    @attrs["certname"]
  end

  def start_time
    @start_time ||= Time.parse(@attrs["start-time"]).utc
  end

  def end_time
    @end_time ||= Time.parse(@attrs["end-time"]).utc
  end

  def duration
    end_time.to_i - start_time.to_i
  end

  def to_json(*args)
    @attrs.to_json(*args)
  end

  def key
    self.class.key(certname, hash)
  end

  def index(name)
    self.class.index(certname, name)
  end

  def nodeless_index(name)
    self.class.index(nil, name)
  end

  def exists?
    self.class.exists?(certname, key)
  end

  def stats
    @stats ||= ReportStats.new(@attrs["_stats"])
  end

  def save
    nodeless_index(:all).add    start_time, key
    nodeless_index(:active).add start_time, key if stats.active?
    nodeless_index(:failed).add start_time, key if stats.failed?

    index(:all).add    start_time, key
    index(:active).add start_time, key if stats.active?
    index(:failed).add start_time, key if stats.failed?

    Storage[key].add self
    self
  end
end
