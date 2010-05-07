require 'rubygems'
require 'test/unit'
require 'postage'

require 'redgreen' unless ENV['TM_FILEPATH']

class Test::Unit::TestCase
  
  # Most of the tests are hitting actual PostageApp application
  # Thus we need configuration that works
  def setup
    # resetting postage configs
    Postage.configure do |config|
      config.api_key            = '1234567890abcdef'
      config.url                = 'http://api.postageapp.local'
      config.recipient_override = nil
      config.logger = Logger.new("#{File.expand_path('../tmp', File.dirname(__FILE__))}/postage_test.log")
      config.failed_calls_path = File.expand_path('../tmp', File.dirname(__FILE__))
    end
  end
  
end