require 'json'
require 'time'

class NodeReport
  class << self
    def create(json, events)
      stats = ReportStats.build(events)
      NodeReport.new(json, :stats => stats.attrs).save
    end

    def latest_keys(*args)
      options = args.pop if args.last.is_a?(Hash)
      options ||= {}
      node_name = args.first
      from = options[:from]
      params = {}
      if options[:limit]
        params[:limit] = [options[:offset] || 0, options[:limit]]
      end
      from ||= Time.at(Time.now.to_i - i30_days)
      to = Time.now
      key = nil
      if node_name
        key = options[:active] ? index(node_name, :active) : index(node_name, :all)
      else
        key = index(nil, :all)
      end
      redis.zrevrangebyscore key, to.to_i, from.to_i, params
    end

    def latest(*args)
      keys = latest_keys(*args)
      return [] if keys.empty?
      reports = redis.mget(keys)
      reports.map!{|i| NodeReport.new i }
    end

    def key(node_name, hash)
      "db:node:#{node_name}:reports:#{hash}"
    end

    def index(node_name, idx)
      if node_name == nil
        "db:index:node_reports:#{idx}"
      else
        "db:index:node:#{node_name}:reports:#{idx}"
      end
    end

    def exists?(node_name, hash)
      !!redis.zrank(index(node_name, :all), key(node_name, hash))
    end

    def redis
      App.redis
    end

    private
      def i30_days
        60 * 60 * 24 * 30
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
    self.class.exists?(certname, hash)
  end

  def stats
    @stats ||= ReportStats.new(@attrs["_stats"])
  end

  def save
    redis.zadd index(:all), start_time.to_i, key
    redis.zadd nodeless_index(:all), start_time.to_i, key
    redis.zadd index(:active), start_time.to_i, key if stats.active?
    redis.set key, to_json
    self
  end

  private
    def redis
      self.class.redis
    end
end
