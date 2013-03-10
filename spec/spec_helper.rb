ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', 'boot.rb')
require File.join(File.dirname(__FILE__), '..', 'spec', 'support', 'redis')

RSpec.configure do |config|
  config.include RedisSpecHelper
end
