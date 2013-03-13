module RedisSpecHelper
  def self.included(base)
    base.extend ClassMethods
  end

  def redis
    App.redis
  end

  def r_get(*args)
    redis.get(*args)
  end

  def r_zrange(key)
    redis.zrange key, 0, -1, :withscores => true
  end

  def cleanup_redis!
    redis.keys("*").each do |key|
      redis.del key
    end
  end

  module ClassMethods
    def cleanup_redis!
      before do
        cleanup_redis!
      end
    end
  end
end
