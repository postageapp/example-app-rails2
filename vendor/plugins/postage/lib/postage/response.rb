require 'ostruct'

# A simple wrapper around responses. Generally there are following methods available:
#
#   response
#   api
#   data
#
class Postage::Response < OpenStruct
  
  def success?
    self.response['status'] == 'ok'
  rescue
    false
  end
  
  def error?
    !success?
  end
  
end