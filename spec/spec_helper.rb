ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', 'boot.rb')
require File.join(File.dirname(__FILE__), '..', 'spec', 'support', 'redis')
require File.join(File.dirname(__FILE__), '..', 'spec', 'support', 'fixtures')

RSpec.configure do |config|
  config.include RedisSpecHelper
  config.include FixturesSpecHelper
  config.mock_with :rr
end
