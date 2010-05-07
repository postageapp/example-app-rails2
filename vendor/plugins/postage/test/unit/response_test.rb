require File.dirname(__FILE__) + '/../test_helper'

class ConfigurationTest < Test::Unit::TestCase
  
  def test_default_response
    response = Postage::Response.new(
      :response => {
        'uid'    => '1234567890.12345',
        'status' => 'ok'
      },
      :api => {
        'version'  => '1.0',
        'key'      => 'abcdefg12345'
      },
      :data => {
        'something' => 'blah'
      }
    )
    
    assert response.success?
    assert !response.error?
    
    assert_equal ({"uid"=>"1234567890.12345", "status"=>"ok"}), response.response
    assert_equal ({"version"=>"1.0", "key"=>"abcdefg12345"}), response.api
    assert_equal ({"something"=>"blah"}), response.data
  end
  
end