require 'rubygems'
require 'bundler'
require 'json'

module Application
  class << self
    def root
      @root ||= Pathname.new(File.expand_path(__FILE__ + "/../"))
    end

    def env
      @env ||= (ENV['RACK_ENV'] || 'development').to_sym
    end

    def redis
      @redis ||= begin
        url = ENV['REDIS_URL'] || "localhost:6379/0"
        redis = Redis.new url: "redis://#{url}"
        Redis::Namespace.new("puppetdb-db:#{env}", :redis => redis)
      end
    end

    def cache(key, options = {}, &block)
      if value = redis.get(key)
        puts "[cache] HIT '#{key}'"
        JSON.parse(value)
      else
        puts "[cache] MISS '#{key}'"
        ttl = options[:ttl] || 60 * 30
        value = yield
        redis.set(key, value.to_json)
        if ttl > 0
          redis.expire(key, ttl)
        end
        value
      end
    end
  end
end

Bundler.require(:default, :assets, Application.env)

require './lib/application'
require './lib/home'
require './lib/api'
require './lib/puppetdb/client'

