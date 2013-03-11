ENV['RACK_ENV'] = 'test'

require 'webmock'
require 'webmock/rspec'

require 'sidekiq'
require 'sidekiq/testing'

require 'timecop'

require File.join(File.dirname(__FILE__), '..', 'boot.rb')
require File.join(File.dirname(__FILE__), '..', 'spec', 'support', 'redis')
require File.join(File.dirname(__FILE__), '..', 'spec', 'support', 'fixtures')

RSpec.configure do |config|
  config.include RedisSpecHelper
  config.include FixturesSpecHelper
  config.mock_with :rr
end
