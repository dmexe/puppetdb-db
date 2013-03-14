class Index
  attr_reader :key

  class << self
    def [](key)
      @indexes ||= {}
      @indexes[key] ||= Index.new(key)
    end
  end

  def initialize(key)
    @key = "db:index:#{key}"
  end

  def add(value, content)
    redis.zadd key, value.to_i, content
  end

  def exists?(content)
    !!redis.zrank(key, content)
  end

  def all(*args)
    options = args.pop if args.last.is_a?(Hash)
    options ||= {}
    params  = {}
    from    = options[:from]  || Time.at(Time.now.to_i - i30_days)
    to      = options[:to]    || Time.now
    order   = options[:order] || :desc
    if options[:limit]
      params[:limit] = [options[:offset] || 0, options[:limit]]
    end
    params[:withscores] = true if options[:score]

    if order == :asc
      redis.zrangebyscore key, from.to_i, to.to_i, params
    else
      redis.zrevrangebyscore key, to.to_i, from.to_i, params
    end
  end

  def redis
    App.redis
  end

  private

    def i30_days
      60 * 60 * 24 * 30
    end
end
