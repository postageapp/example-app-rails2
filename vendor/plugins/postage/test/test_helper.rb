ENV["RAILS_ENV"] = "plugin_test"

require 'rubygems'
require 'test/unit'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'active_support'
require 'action_mailer'
require 'redgreen' unless ENV['TM_FILEPATH']
require 'yaml'

require 'postage'

class Test::Unit::TestCase
  
  def setup
    # setting up initial plugin settings
    Postage.configure do |config|
      config.api_key            = '1234567890abcdef'
      config.api_version        = '1.0'
      config.url                = 'http://api.postageapp.local'
      config.recipient_override = 'oleg@twg.test'
      config.environments       = ['production', 'staging', 'plugin_test']
    end
  end
  
end
