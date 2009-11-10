module Postage
  
  PLUGIN_VERSION  = '0.0.3'
  API_VERSION     = '1.0'
  
  require 'logger'
  require 'postage/request'
  require 'postage/response'
  require 'postage/mailer' if defined?(ActionMailer)
  
  class << self
    attr_accessor :api_key,
                  :api_version,
                  :url,
                  :recipient_override,
                  :environments,
                  :log,
                  :stored_failed_requests,
                  :stored_failed_requests_path
  end
    
  # Logging mechanism
  def self.log
    logfile_path = if defined?(Rails)
      "#{Rails.root}/log/postage_#{Rails.env}.log"
    else
      "#{File.expand_path('../test', File.dirname(__FILE__))}/postage_test.log"
    end
    
    @log ||= begin
      logfile = File.open(logfile_path, 'a')
      logfile.sync = true
      Logger.new(logfile)
    end
  end
    
  # API version on the PostageApp server
  def self.api_version
    @api_version ||= API_VERSION
  end
    
  # Url plugin is using to communicated with PostageApp
  def self.url
    @url ||= 'http://api.postageapp.com'
  end
    
  # Defines Rails environments when Postage kicks in instead of ActiveMailer
  # This so we don't send messages during development / testing when it's not
  # neccessary to hit PostageApp
  def self.environments
    @environments ||= ['production', 'staging', 'development']
  end
  
  # If a request fails we can store it as a file and re-send it later on.
  # Here's a list of requests that we care to store:
  def self.stored_failed_requests
    @stored_failed_requests ||= ['send_message']
  end
  
  # A path where those requests are saved
  def self.stored_failed_requests_path
    @stored_failed_requests_path ||= File.expand_path('../stored_requests', File.dirname(__FILE__))
  end
    
  # Set up this configuration in /config/initializers/postage.rb
  # You may override all defaults that were specified above.
  # 
  #   Postage.configure do |config|
  #     config.api_key = '1234567890abcdef'
  #   end
  #
  def self.configure
    yield self
  end
  
  # Sends a message to PostageApp service.
  # Accepts following parameters:
  #
  #   :message -- a hash of content with mimetype as a key. Most common use:
  #     { 'text/plain' => 'html message content',
  #       'text/html'  => 'plain text content' }
  #     also takes a hash of attachments:
  #     { 
  #       'attachments' => {
  #         'filename.ext' => {
  #           'content_type'  => 'attachment_content_type',
  #           'content'       => 'Base64_encoded_content'
  #         }
  #       }
  #     }
  #
  #   :template_name -- should match message template name that you have
  #     defined in your PostageApp account. Think of it as a Rails template
  #     that wraps your message and outputs defined message variables.
  #
  #   :recipients -- A list of emails your message goes to. Could be in several
  #     formats. A string, an array of strings, or hash that defines recipients
  #     as keys and values as a hash of variables that apply to that recipient:
  #     { 'bob@postageapp.com' => {'first_name' => 'Bob'} }
  #
  #   :variables -- A hash of variables that can be applied by the message
  #     template (provided it's available) or message content you send along.
  #     { 'users_registered_so_far' => User.count }
  #
  #   :headers -- A hash of your standard email headers. Example of one you want:
  #     { 'Subject' => 'This is my messge' }
  #
  # Returns Postage::Response object, or nil if request never happened.
  def self.send_message(options = {})
    unless Postage.recipient_override.blank?
      options[:recipient_override] = Postage.recipient_override
    end
    Postage::Request.new(:send_message, options).call!
  end
end

