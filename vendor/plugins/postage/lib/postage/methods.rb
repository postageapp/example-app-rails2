module Postage::Methods
  class << self
    # Sends a message to PostageApp service.
    # Accepts following parameters:
    #
    #   :content -- a hash of content with mimetype as a key. Most common use:
    #     { 'text/plain' => 'html message content',
    #       'text/html'  => 'plain text content' }
    #
    #   :attachments -- a hash that defines attaches files and their content
    #     { 'filename.ext' => {
    #         'content_type'  => 'attachment_content_type',
    #         'content'       => 'Base64_encoded_content' }}
    #
    #   :template -- should match message template name that you have
    #     defined in your PostageApp account. Think of it as a Rails template
    #     that wraps your message and outputs defined message variables.
    #
    #   :recipients -- A list of emails your message goes to. Could be in several
    #     formats. A string, an array of strings, or a hash that defines recipients
    #     as keys and values as a hash of variables that apply to that recipient:
    #     { 'bob@postageapp.com' => {'first_name' => 'Bob'} }
    #
    #   :variables -- A hash of variables that can be applied by the message
    #     template (provided it's available) or message content you send along.
    #     { 'users_registered_so_far' => User.count }
    #
    #   :headers -- A hash of your standard email headers. Example of one you want:
    #     { 'subject' => 'This is my message' }
    #
    #   :recipient_override -- email address that message will be sent to, recipients
    #     are going to be ignored
    #
    # Returns Postage::Response object, or nil if request never happened.
    #
    def send_message(options = {})
      unless Postage.recipient_override.blank?
        options[:recipient_override] = Postage.recipient_override
      end
      Postage::Request.new(:send_message, options).call
    end
    
    def method_missing(method_name, *args) #:nodoc:#
      Postage::Request.new(method_name, *args).call
    end
  end
end