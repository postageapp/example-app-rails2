# Postage plugin acts as an API interface to PostageApp.com
# 
# Example configuration (usually found in /config/intializers/postage.rb):
# 
#   Postage.configure do |config|
#     config.api_key = 'YOUR_API_KEY_HERE'
#   end
# 
# You may set up following configuration parameters:
# 
#   api_key             - key provided to you when you create a project on PostageApp.com
#   url                 - http://api.postageapp.com is the default address
#   recipient_override  - All calls to send message will attach provided email address.
#   logger              - You may define your own custom logger. By default postage 
#                         activity will be logged to postage_RAILS_ENV.log file
#   failed_calls        - Names of request types that plugin can store and re-try later. 
#                         By default it's ['send_message']
#   failed_calls_path   - Path where failed requests are stored
# 
# 
# There are two ways to interface with your PostageApp project. One by utilizing 
# provided Postage::Mailer class (see mailer.rb for details) and the more direct 
# Postage.call!(api_method_name, parameters) way
# 
# Example:
# 
#   Postage.call(:send_message, :template => 'my_template', :recipients => 'oleg@twg.ca')
# 
# Example above will return a Postage::Response object (a glorified hash) if successful
#
module Postage
  
  PLUGIN_VERSION  = '1.0.1'
  API_VERSION     = '1.0'
  
  require 'postage/request'
  require 'postage/response'
  require 'postage/methods'
  require 'postage/mailer'
  require 'logger'
  
  class << self
    attr_accessor :api_key,
                  :url,
                  :recipient_override,
                  :logger,
                  :failed_calls,
                  :failed_calls_path
    
    def url
      @url ||= 'http://api.postageapp.com'
    end
    
    def failed_calls
      @failed_calls ||= ['send_message']
    end
    
    def failed_calls_path
      @failed_calls_path ||= File.join(RAILS_ROOT, 'tmp', 'stored_requests')
    end
    
    def logger
      @logger ||= Logger.new(File.join(RAILS_ROOT, 'log', "postage_#{RAILS_ENV}.log"))
    end
    
    def configure
      yield self
    end
    
    def call(method, arguments = {})
      Postage::Methods.send(method, arguments)
    end
  end
end
