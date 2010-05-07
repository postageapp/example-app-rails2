require File.dirname(__FILE__) + '/../test_helper'

class PostageTest < Test::Unit::TestCase
  
  def test_default_config
    assert_equal '1234567890abcdef', Postage.api_key
    assert_equal 'http://api.postageapp.local', Postage.url
    assert_equal ['send_message'], Postage.failed_calls
  end
  
  def test_asetting_config
    Postage.configure do |c|
      c.api_key             = 'new_api_key'
      c.url                 = 'http://newurl.test'
      c.recipient_override  = 'oleg@test.test'
    end
    
    assert_equal 'new_api_key', Postage.api_key
    assert_equal 'http://newurl.test', Postage.url
    assert_equal 'oleg@test.test', Postage.recipient_override
  end
  
  def test_call
    response = Postage.call(:get_account_info)
    assert response.success?
  end
  
end