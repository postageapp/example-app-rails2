# Postage::Request.api_method maps to the possible actions on the PostageApp
# current list is: get_method_list, get_project_info, send_message

class Postage::Request
  
  require 'httparty'
  include HTTParty
  format :json
  
  HEADERS = {
    'Content-type'             => 'application/json',
    'Accept'                   => 'text/json, application/json',
    'X-Postage-Client-Name'    => 'PostagePlugin',
    'X-Postage-Client-Version' => Postage::PLUGIN_VERSION
  }
  
  attr_accessor :api_method,
                :arguments,
                :response
  
  def initialize(api_method = nil, arguments = {})
    @api_method = api_method
    @arguments  = arguments || {}
  end
  
  def call_url
    "#{Postage.url}/v.#{Postage.api_version}/#{self.api_method}.json"
  end
  
  def uid
    @uid ||= Time.now.to_f.to_s
  end
  
  # Returns a json response as recieved from the PostageApp server
  # Upon internal failure nil is returned
  def call!(call_url = self.call_url, arguments = self.arguments)
    Postage.log.info "Sending Request [UID: #{self.uid} URL: #{call_url}] \n#{arguments.inspect}\n"
    
    # aborting if we are not supposed to contact PostageApp
    unless Postage.environments.include?(defined?(Rails) ? Rails.env : ENV['RAILS_ENV'])
      Postage.log.info "Not contacting PostageApp server. Sending back test response."
      return Postage::Response.test_response
    end
    
    self.arguments[:uid]              = self.uid
    self.arguments[:plugin_version]   = Postage::PLUGIN_VERSION
    
    body = { :api_key => Postage.api_key, :arguments => arguments }.to_json
    
    Timeout::timeout(5) do
      self.response = self.class.post( call_url, 
        :headers  => HEADERS,
        :body     => body
      )
    end
    
    Postage.log.info "Received Response [UID: #{self.uid}] \n#{self.response.inspect}\n"
    
    Postage::Response.new(self.response)
    
  rescue Timeout::Error, SocketError, Exception => e
    Postage.log.error "Failure [UID: #{self.uid}] \n#{e.inspect}"
    
    store_failed_request
    
    return nil # no response generated
  end
  
protected
  
  def store_failed_request
    return unless Postage.stored_failed_requests.include?(self.api_method.to_s)
    
    unless File.exists?(Postage.stored_failed_requests_path)
      FileUtils.mkdir_p(Postage.stored_failed_requests_path)
    end
    
    open(File.join(Postage.stored_failed_requests_path, "#{self.uid}.yaml"), 'w') do |f|
      f.write({:url => self.call_url, :arguments => self.arguments}.to_yaml)
    end
  end
  
end
