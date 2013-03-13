require 'json'

class ReportStats
  class << self
    def key(hash)
      "db:reports:#{hash}:stats"
    end

    def create(report, node_report)
      summary = report.events.inject({}) do |ac, event|
        status = event["status"]
        ac[status] ||= 0
        ac[status] += 1
        ac
      end
      summary.merge!("hash"      => report.hash,
                     "duration"  => node_report.duration,
                     "timestamp" => node_report.start_time.to_i)
      populate(summary).save
    end

    def find(hashes)
      hashes = [hashes] unless hashes.is_a?(Array)
      return [] if hashes.empty?
      reports = redis.mget hashes.map{|i| key(i) }
      reports.compact!
      reports.map! do |report|
        populate report if report
      end
      reports
    end

    def redis
      App.redis
    end

    private
      def populate(json, options = {})
        ReportStats.new json, options
      end
  end

  attr_reader :attrs, :hash

  def initialize(json, options = {})
    raise ArgumentError unless json
    if json.is_a?(String)
      json = JSON.parse(json)
    end
    @attrs  = json
    @hash   = options[:hash] || @attrs["hash"]
    raise ArgumentError unless @hash
  end

  def skipped
    @attrs["skipped"] || 0
  end

  def success
    @attrs["success"] || 0
  end

  def failure
    @attrs["failure"] || 0
  end

  def duration
    @attrs["duration"]
  end

  def timestamp
    Time.at(@attrs["timestamp"]).utc
  end

  def to_json
    @attrs.to_json
  end

  def save
    redis.set key, to_json
    self
  end

  def active?
    (success + failure) > 0
  end

  def exists?
    redis.exists key
  end

  def key
    self.class.key hash
  end

  private
    def redis
      self.class.redis
    end
end
