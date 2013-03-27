require 'json'
require 'time'

require App.root.join("lib", 'activesupport', 'hash', 'keys')

class Report
  class << self
    def create(attrs)
      new(attrs).save
    end

    def key(node, hash)
      (node and hash) or raise ArgumentError
      "nodes:#{node}:reports:#{hash}"
    end

    def id_to_key(id)
      id = id.split(":")
      (id.size == 2) or raise ArgumentError
      key(*id)
    end

    def index
      Index['reports']
    end

    def get(ids)
      ids = [ids] unless ids.is_a?(Array)
      keys = ids.map{|i| id_to_key(i) }
      (Storage.get(keys) || []).map! do |report|
        new report
      end
    end

    def first(id)
      get([id]).first
    end
  end

  attr_reader :node, :time, :version, :duration, :digest, :success, :failed, :skipped, :events

  def initialize(attributes)
    attributes = JSON.parse(attributes) if attributes.is_a?(String)
    attributes.each_pair do |k,v|
      self.__send__ "#{k}=", v
    end
  end

  def id
    "#{node}:#{digest}"
  end

  def node=(val)
    @node = val.to_s.strip.empty? ? nil : val.to_s.strip
  end

  def time=(val)
    @time = if val.respond_to?(:to_time)
              val.to_time
            elsif val.is_a?(String)
              Time.parse(val) rescue nil
            end
  end

  def version=(val)
    @version = val.to_i
  end

  def duration=(val)
    @duration = val.to_f
  end

  def digest=(val)
    @digest = val.to_s.strip.empty? ? nil : val.to_s.strip
  end

  def success=(val)
    @success = val.to_i
  end

  def failed=(val)
    @failed = val.to_i
  end

  def skipped=(val)
    @skipped = val.to_i
  end

  def events=(val)
    @events = val.is_a?(Array) ? val : []
  end

  def valid?
    node && digest
  end

  def to_hash
    {
      :node     => node,
      :time     => time,
      :version  => version,
      :duration => duration,
      :digest   => digest,
      :success  => success,
      :failed   => failed,
      :skipped  => skipped
    }
  end

  def to_json
    to_hash.to_json
  end

  def save
    if valid?
      index.add time, key
      Storage[key].add self
      self
    end
  end

  def key
    self.class.key node, digest
  end

  def index
    self.class.index
  end

  class Invalid < Exception ; end
end
