require 'json'
require 'time'

class Report
  class << self
    def create(json)
      new(json).save
    end

    def key(hash)
      "reports:#{hash}"
    end

    def index
      Index['reports']
    end

    def get(hashes)
      hashes = [hashes] unless hashes.is_a?(Array)
      hashes = hashes.map{|i| key(i) }
      reports = Storage.get hashes
      reports = (reports || []).map do |report|
        new report
      end
      reports
    end

    def first(hash)
      get([hash]).first
    end
  end

  attr_reader :events, :hash

  def initialize(events, options = {})
    events  = JSON.parse(events) if events.is_a?(String)
    @events = events
    @hash   = options[:hash] || (@events.first && @events.first["report"])
    raise ArgumentError unless @hash
  end

  def to_json
    @events.to_json
  end

  def save
    index.add timestamp, key
    Storage[key].add self
    self
  end

  def timestamp
    @timestamp ||= Time.parse(@events.first["timestamp"]).utc
  end

  def key
    self.class.key hash
  end

  def index
    self.class.index
  end
end
