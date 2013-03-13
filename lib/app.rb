require 'sinatra'
require 'pathname'

module App

  class << self
    def root
      @root ||= Pathname.new(File.expand_path(__FILE__ + "/../../"))
    end

    def env
      @env ||= (ENV['RACK_ENV'] || 'development').to_sym
    end

    def puppetdb
      PuppetDB.inst
    end

    def redis
      require 'redis-namespace'

      @redis ||= begin
        url = ENV['REDIS_URL'] || "localhost:6379/0"
        redis = Redis.new url: "redis://#{url}"
        Redis::Namespace.new("puppetdb-db:#{env}", :redis => redis)
      end
    end

    def cache(key, options = {}, &block)
      require 'json'

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

    def assets
      require 'sprockets'
      require 'sass'
      require 'coffee_script'
      require 'eco'

      environment = Sprockets::Environment.new
      environment.append_path     'assets/javascripts'
      environment.append_path     'assets/stylesheets'
      environment.append_path     'assets/images'
      # environment.js_compressor = Uglifier.new(:copyright => false)
      # environment.css_compressor = YUI::CssCompressor.new
      environment
    end
  end

  class Web < ::Sinatra::Base
    set :root,    App.root.to_s
    set :views,   App.root.join("views").to_s
    set :logging, true
  end
end

