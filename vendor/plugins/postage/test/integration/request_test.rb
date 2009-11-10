require File.dirname(__FILE__) + '/../test_helper'

class RequestTest < Test::Unit::TestCase
  
  def setup
    super
    # This tests runs against real postageapp deployment, thus make sure it's accessible
    # You can put your project's API key and real production url 'api.postageapp.com'
    #   Postage.url     = 'http://api.postageapp.com'
    #   Postage.api_key = 'your_api_key'
  end
  
  def test_request_setup  
    r = Postage::Request.new(:get_method_list)
    assert_equal :get_method_list, r.api_method
    assert_equal 'http://api.postageapp.local/v.1.0/get_method_list.json', r.call_url
    assert !r.uid.blank?
  end
  
  def test_request_call
    r = Postage::Request.new(:get_method_list)
    response = r.call!
    assert response.success?
    assert_equal 'ok', response[:response][:status]
    assert_equal r.uid, response[:response][:uid]
    assert !response.data.blank?
  end
  
  def test_request_call_failure
    r = Postage::Request.new(:get_method_that_does_not_exist)
    response = r.call!
    assert response.error?
    assert_equal 'internal_server_error', response[:response][:status]
    assert_equal r.uid, response[:response][:uid]
  end
  
  def test_request_call_timeout
    Postage.url = 'http://not_valid_site.test'
    r = Postage::Request.new(:get_method_list)
    response = r.call!
    assert !response
  end
  
  def test_request_in_test_mode
    Postage.environments = ['production']
    r = Postage::Request.new(:get_method_list)
    response = r.call!
    assert response.success?
    assert_equal 'This is a sample response', response.response[:message]
  end
  
  def test_request_failure_and_storing_to_file
    assert_equal ['send_message'], Postage.stored_failed_requests
    Postage.url = 'http://not_valid_site.test'
    arguments = {
      :message    => {  'text/plain' => 'plain text message',
                        'text/html'  => 'html text message' },
      :recipients => 'oleg@twg.test' 
    }
    r = Postage::Request.new(:send_message, arguments)
    assert r.uid
    response = r.call!
    assert !response
    
    filename = File.join(Postage.stored_failed_requests_path, "#{r.uid}.yaml")
    assert File.exists?(filename)
    file = YAML::load_file(filename)
    assert_equal r.call_url, file[:url]
    assert_equal r.arguments, file[:arguments]
  end
  
end
