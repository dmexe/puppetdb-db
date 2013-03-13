require 'json'

class ReportStats

  class << self
    def build(json)
      json = JSON.parse(json) if json.is_a?(String)
      stats = json.inject({}) do |h, event|
        status = event["status"]
        h[status] ||= 0
        h[status] += 1
        h
      end
      ReportStats.new(stats)
    end
  end

  attr_reader :attrs

  def initialize(attrs)
    raise ArgumentError unless attrs.is_a?(Hash)
    @attrs = attrs
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

  def to_json
    @attrs.to_json
  end

  def active?
    (success + failure) > 0
  end

  def failed?
    failure > 0
  end
end
