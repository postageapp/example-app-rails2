require File.dirname(__FILE__) + '/../test_helper'

class RequestMethodsTest < Test::Unit::TestCase
  
  def setup
    super
    # This tests runs against real postageapp deployment, thus make sure it's accessible
    # You can put your project's API key and real production url 'api.postageapp.com'
    #   Postage.url     = 'http://api.postageapp.com'
    #   Postage.api_key = 'your_api_key'
  end
  
  def test_get_method_list
    response = Postage::Request.new(:get_method_list).call!
    assert response.success?
    assert !response.data.blank?
    assert_equal ({"methods"=>"get_account_info, get_method_list, get_project_info, send_message"}), response.data
  end
  
  def test_get_project_info
    response = Postage::Request.new(:get_project_info).call!
    assert response.success?
    assert !response.data.blank?
    assert !response.data[:project].blank?
  end
  
  def test_get_account_info
    response = Postage::Request.new(:get_account_info).call!
    assert response.success?
    assert !response.data.blank?
    assert !response.data[:account].blank?
  end
  
  def test_send_message
    arguments = {
      :content    => {  'text/plain' => 'plain text message',
                        'text/html'  => 'html text message' },
      :recipients => 'oleg@twg.test',
      :headers    => { :subject => 'Plugin Test Message' }
    }
    response = Postage::Request.new(:send_message, arguments).call!
    assert response.success?
    assert !response.data.blank?
    assert !response.data[:message].blank?
  end
  
end