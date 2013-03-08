require 'rubygems'
require 'bundler'

module Application
  class << self
    def root
      @root ||= Pathname.new(File.expand_path(__FILE__ + "/../"))
    end

    def env
      @env ||= (ENV['RACK_ENV'] || 'development').to_sym
    end
  end
end

Bundler.require(:default, :assets, Application.env)

require './lib/application'
require './lib/home'
require './lib/api'
require './lib/puppetdb/client'

