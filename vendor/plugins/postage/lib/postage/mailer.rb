# By default ActionMailer delivery methods are caught by Postage.
# It makes it easy to convert without the need to interface with Postage
# directly. However, if you contruct your calls manually (not that hard, 
# check documentation) you can disable ActiveMailer on your app completely.
# Like so:
#   config.frameworks -= [ :action_mailer ]

require 'base64'

module Postage::Mailer
  
  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    
    def perform_delivery_postage(mail)
      
      arguments = {
        :headers => {
          'Subject' => self.subject, 
          'From'    => self.from
        }.merge(self.headers),
        :parts => { }
      }
      
      # Collect the parts
      if self.parts.blank?
        arguments[:parts][self.content_type] = self.body
      else
        self.parts.each do |part|
          case part.content_disposition
          when 'inline'
            arguments[:parts][part.content_type] = part.body
          when 'attachment'
            arguments[:parts][:attachments] ||= { }
            arguments[:parts][:attachments][part.filename] = {
              :content_type => part.content_type,
              :content      => Base64.encode64(part.body)
            }
          end
        end
      end
      
      logger.info  "Sending mail via Postage..." unless logger.nil?
      
      response = Postage.send_message(
        :message    => arguments[:parts],
        :recipients => self.recipients,
        :headers    => arguments[:headers]
      )
      
      unless logger.nil?
        logger.info  "Mail successfully sent. Check postage_#{Rails.env}.log for more details. UID: #{response.response[:uid]}"
      end
      
      return response
      
    rescue => e
      Postage.log.error "Failed to perform delivery with postage: \n#{e.inspect}"
      raise e
    end
  end
end

ActionMailer::Base.send :include, Postage::Mailer
ActionMailer::Base.delivery_method = :postage

# Violent override of the default ActionMailer deliver! method
# maybe there's a better way of doing this.
class ActionMailer::Base
  def deliver!(mail = @mail)
    raise "no mail object available for delivery!" unless mail
    
    begin
      response = __send__("perform_delivery_#{delivery_method}", mail) if perform_deliveries
    rescue Exception => e  # Net::SMTP errors or sendmail pipe errors
      raise e if raise_delivery_errors
    end
    # this is the key overide. Instead of returning somewhat useless TMail object, we are more
    # interested in the PostageApp's response
    return response
  end
end