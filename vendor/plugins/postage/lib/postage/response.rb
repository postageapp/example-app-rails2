class Postage::Response < HashWithIndifferentAccess
  
  # Just a fake response that can be used in testing environment
  def self.test_response
    self.new(
      :response => {
        :status   => 'ok',
        :message  => 'This is a sample response'
      }
    )
  end
  
  def success?
    self[:response][:status].to_s == 'ok'
  rescue
    false
  end
  
  def error?
    !success?
  end
  
  # -- Logical partitions of the response -----------------------------------
  def response
    self[:response]
  end
  
  def api
    self[:api]
  end
  
  def data
    self[:data]
  end
  
end