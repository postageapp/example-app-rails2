# Your standard wrapper for API calls to PostageApp
# 
# Example:
# 
#   request = Postage::Request.new(:api_method_name, :some => 'options')
#   response = request.call # sets up a call and grabs a response from PostageApp
# 
# Failed requests (type of which is defined in Postage.failed_calls array) are stored
# on local disk and are resent with the next successful transmission.
#
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
    "#{Postage.url}/v.#{Postage::API_VERSION}/#{self.api_method}.json"
  end
  
  def uid
    @uid ||= Time.now.to_f.to_s
  end
  
  # Returns a json response as recieved from the PostageApp server
  # Upon internal failure nil is returned
  def call(call_url = self.call_url, arguments = self.arguments, resending = false)
    Postage.logger.info "Sending Request [UID: #{self.uid} URL: #{call_url}] \n#{arguments.inspect}\n"
    
    self.arguments[:uid]              = self.uid
    self.arguments[:plugin_version]   = Postage::PLUGIN_VERSION
    
    body = { :api_key => Postage.api_key, :arguments => arguments }.to_json
    
    Timeout::timeout(5) do
      self.response = self.class.post( call_url, :headers => HEADERS, :body => body )
    end
    
    Postage.logger.info "Received Response [UID: #{self.uid}] \n#{self.response.inspect}\n"
    
    resend_failed_requests unless resending
    return Postage::Response.new(self.response)
    
  rescue Timeout::Error, SocketError, Exception => e
    Postage.logger.error "Failure [UID: #{self.uid}] \n#{e.inspect}"
    
    store_failed_request(e) unless resending 
    return nil # no response generated
  end
  
protected
  
  def store_failed_request(e)
    return unless Postage.failed_calls.include?(self.api_method.to_s)
    
    # notification for hoptoad users
    HoptoadNotifier.notify(e) if defined?(HoptoadNotifier)
    
    # creating directory, unless if already exists
    FileUtils.mkdir_p(Postage.failed_calls_path) unless File.exists?(Postage.failed_calls_path)
    
    open(File.join(Postage.failed_calls_path, "#{self.uid}.yaml"), 'w') do |f|
      f.write({:url => self.call_url, :arguments => self.arguments}.to_yaml)
    end
  end
  
  def resend_failed_requests(limit = 5)
    file_path = Postage.failed_calls_path
    files = Dir.entries(file_path).select{|f| f.match /\.yaml$/}
    return if files.empty?
    
    Postage.logger.info "-- Attempting to resend #{files[0...limit].size} previously failed requests"
    files[0...limit].each do |file|
      data = YAML::load_file(File.join(file_path, file))
      if Postage::Request.new.call(data[:url], data[:arguments], true)
        Postage.logger.info '-- Send was successful. Removing stored file.'
        FileUtils.rm File.join(file_path, file)
      else
        Postage.logger.info '-- Failed to resend'
      end
    end
  rescue Errno::ENOENT
    # do nothing, we never had failed requests
  end
end
