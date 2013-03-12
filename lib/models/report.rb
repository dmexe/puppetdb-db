require 'json'
require 'time'

class Report
  class << self
    def populate(json)
      Report.new json
    end

    def key(hash)
      "db:reports:#{hash}"
    end

    def index_key
      "db:reports"
    end

    def find_keys(from = nil)
      from ||= Time.at(Time.now.to_i - i30_days)
      to = Time.now
      redis.zrevrangebyscore index_key, to.to_i, from.to_i
    end

    def find(hashes)
      hashes = [hashes] unless hashes.is_a?(Array)
      reports = redis.mget hashes.map{|i| key(i) }
      reports.compact!
      reports.map! do |report|
        populate report
      end
      reports
    end

    def first(hash)
      find([hash]).first
    end

    def redis
      Application.redis
    end

    private
      def i30_days
        60 * 60 * 24 * 30
      end
  end

  attr_reader :events, :hash

  def initialize(events, options = {})
    if events.is_a?(String)
      events = JSON.parse(events)
    end
    @events = events
    @hash   = options[:hash] || (@events.first && @events.first["report"])
    raise ArgumentError unless @hash
  end

  def to_json
    @events.to_json
  end

  def save
    redis.set key, to_json
    redis.zadd index_key, timestamp.to_i, key
  end

  def timestamp
    @timestamp ||= Time.parse(@events.first["timestamp"]).utc
  end

  def key
    self.class.key hash
  end

  def index_key
    self.class.index_key
  end

  private
    def redis
      self.class.redis
    end
end
