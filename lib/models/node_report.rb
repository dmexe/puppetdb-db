require 'json'
require 'time'

class NodeReport
  class << self
    def populate(json)
      json.map! do |it|
        NodeReport.new it
      end
    end

    def find_keys_by_node(node_name, options = {})
      from = options[:from]
      params = {}
      if options[:limit]
        params[:limit] = [options[:offset] || 0, options[:limit]]
      end
      from ||= Time.at(Time.now.to_i - i30_days)
      to = Time.now
      redis.zrevrangebyscore index_key(node_name), to.to_i, from.to_i, params
    end

    def find_by_node(node_name, options = {})
      keys = find_keys_by_node(node_name, options)
      return [] if keys.empty?
      reports = redis.mget(keys)
      populate reports
    end

    def find_by_node_with_summary(node_name, options = {})
      node_reports = find_by_node(node_name, options)
      hashes = node_reports.map{|i| i.hash }
      summaries = ReportSummary.find(hashes)
      node_reports.each do |node_report|
        sum = summaries.find{|i| i.hash == node_report.hash }
        node_report.attrs["_summary"] = sum.attrs
      end
      node_reports
    end

    def key(node_name, hash)
      "db:node:#{node_name}:reports:#{hash}"
    end

    def index_key(node_name)
      "db:node:#{node_name}:reports"
    end

    def exists?(node_name, hash)
      !!redis.zrank(index_key(node_name), key(node_name, hash))
    end

    def redis
      Application.redis
    end

    private
      def i30_days
        60 * 60 * 24 * 30
      end
  end

  attr_reader :attrs

  def initialize(attrs)
    if attrs.is_a?(String)
      attrs = JSON.parse(attrs)
    end
    @attrs = attrs
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

  def index_key
    self.class.index_key(certname)
  end

  def exists?
    self.class.exists?(certname, hash)
  end

  def save
    redis.set key, to_json
    redis.zadd index_key, start_time.to_i, key
  end

  private
    def redis
      self.class.redis
    end
end
