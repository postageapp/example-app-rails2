require File.dirname(__FILE__) + '/../test_helper'

class PostageTest < Test::Unit::TestCase
  
  def test_config
    assert_equal '1234567890abcdef', Postage.api_key
    assert_equal 'http://api.postageapp.local', Postage.url
    assert_equal 'oleg@twg.test', Postage.recipient_override
    assert_equal ['production', 'staging', 'plugin_test'], Postage.environments
    assert_equal ['send_message'], Postage.stored_failed_requests
    assert_equal File.expand_path('../../stored_requests', File.dirname(__FILE__)), 
                  Postage.stored_failed_requests_path
  end
end
