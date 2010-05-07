require File.dirname(__FILE__) + '/../test_helper'

class MethodsTest < Test::Unit::TestCase
  
  def test_get_method_list
    response = Postage.call(:get_method_list)
    assert response.success?
    assert !response.data.blank?
    assert_equal ({"methods"=>"get_account_info, get_method_list, get_project_info, send_message"}), response.data
  end
  
  def test_get_project_info
    response = Postage.call(:get_project_info)
    assert response.success?
    assert !response.data.blank?
    assert !response.data['project'].blank?
  end
  
  def test_get_account_info
    response = Postage.call(:get_account_info)
    assert response.success?
    assert !response.data.blank?
    assert !response.data['account'].blank?
  end
  
  def test_get_project_info
    response = Postage.call(:get_project_info)
    assert response.success?
    assert !response.data.blank?
    assert !response.data['project'].blank?
  end
  
  def test_send_message
    arguments = {
      :content    => {  'text/plain' => 'plain text message',
                        'text/html'  => 'html text message' },
      :recipients => 'oleg@twg.test',
      :headers    => { :subject => 'Plugin Test Message' }
    }
    response = Postage.call(:send_message, arguments)
    assert response.success?
    assert !response.data.blank?
    assert !response.data['message'].blank?
  end
  
  def test_non_existing_method
    response = Postage.call(:non_existing_method)
    assert response.error?
    assert response.data.blank?
    assert_equal 'No action responded to non_existing_method. Actions: get_account_info, get_method_list, get_project_info, render_email, and send_message', response.response['message']
  end
end