ENV['RACK_ENV'] = 'test'

require 'webmock'
require 'webmock/rspec'

require 'sidekiq'
require 'sidekiq/testing'

require 'timecop'

require 'sinatra'
require 'rack/test'

require File.join(File.dirname(__FILE__), '..', 'boot.rb')
require File.join(File.dirname(__FILE__), '..', 'spec', 'support', 'redis')
require File.join(File.dirname(__FILE__), '..', 'spec', 'support', 'fixtures')

def app
  eval "Rack::Builder.new {( " + File.read(File.dirname(__FILE__) + '/../config.ru') + "\n )}"
end

RSpec.configure do |config|
  config.include RedisSpecHelper
  config.include FixturesSpecHelper
  config.include Rack::Test::Methods
  config.mock_with :rr
end
