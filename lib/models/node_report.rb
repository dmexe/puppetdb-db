require 'json'

class NodeReport
  class << self
    def populate(json)
      json.map! do |it|
        NodeReport.new it
      end
    end

    def find_keys_by_node(node_name, fromTime = nil)
      from ||= Time.at(Time.now.to_i - i30_days)
      to = Time.now
      redis.zrangebyscore index_key(node_name), from.to_i, to.to_i
    end

    def find_by_node(node_name, fromTime = nil)
      find_keys_by_node(node_name, fromTime)
      return [] if keys.empty?
      reports = redis.mget(keys)
      populate reports
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

  def to_json
    @attrs.to_json
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
