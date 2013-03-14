require 'json'
require 'time'

class Node
  class << self
    def create(json)
      new(json).save
    end

    def first(name)
      if json = Storage.first(key name)
        new json
      end
    end

    def latest(*args)
      options   = args.pop if args.last.is_a?(Hash)
      options ||= {}
      scope     = args.shift
      keys      = index(scope).all(*(args << options))
      nodes     = Storage.get keys
      nodes.map!{|i| new i }
    end

    def key(node_name)
      "nodes:#{node_name}"
    end

    def index(scope)
      Index["nodes:#{scope}"]
    end
  end

  attr_reader :attrs

  def initialize(attrs, options = {})
    attrs = JSON.parse(attrs) if attrs.is_a?(String)
    @attrs = attrs
  end

  def name
    @attrs["name"]
  end

  def catalog_timestamp
    @catalog_timestamp ||= Time.parse @attrs["catalog_timestamp"]
  end

  def report_timestamp
    @report_timestamp ||= Time.parse @attrs['report_timestamp']
  end

  def facts_timestamp
    @facts_timestamp ||= Time.parse @attrs["facts_timestamp"]
  end

  def to_json(*args)
    @attrs.to_json(*args)
  end

  def key
    self.class.key name
  end

  def index(scope)
    self.class.index(scope)
  end

  def save
    index(:catalog).add catalog_timestamp, key
    index(:report).add  report_timestamp,  key
    index(:facts).add   facts_timestamp,   key

    Storage[key].add self
    self
  end
end

