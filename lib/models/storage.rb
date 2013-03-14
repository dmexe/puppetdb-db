class Storage
  class << self
    def [](val)
      Storage.new(val)
    end

    def first(key)
      get([key]).first
    end

    def get(keys)
      return [] if keys.empty?
      keys.map!{|i| key(i) }
      redis.mget(keys).compact
    end

    def key(name)
      "db:storage:#{name}"
    end

    def redis
      App.redis
    end
  end

  attr_reader :key

  def initialize(key)
    @key = self.class.key(key)
  end

  def add(value)
    value = value.to_json unless value.is_a?(String)
    self.class.redis.set key, value
  end
end
