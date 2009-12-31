module Postage
  require "action_mailer"
  require 'base64'

  class Mailer < ActionMailer::Base
    self.delivery_method = :postage if defined?(Rails) && !Rails.env.test?

    # Allows you to specify wich PostageApp template you want to use
    def postageapp_template(template = nil)
      if template.nil?
        @postageapp_template
      else
        @postageapp_template = template
      end
    end

    def postageapp_variables(variables = nil)
      if variables.nil?
        @postageapp_variables
      else
        @postageapp_variables = variables
      end
    end


    # Delivers an email through PostageApp
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
    
      api_params = {
        :content    => arguments[:parts],
        :recipients => self.recipients,
        :headers    => arguments[:headers]
      }
      api_params[:template] = postageapp_template unless postageapp_template.blank?
      api_params[:variables] = postageapp_variables unless postageapp_variables.blank?
      response = Postage.send_message(api_params)
    
      unless logger.nil?
        logger.info  "Mail successfully sent. Check postage_#{Rails.env}.log for more details. UID: #{response.response[:uid]}"
      end
    
      return response
    
    rescue => e
      Postage.log.error "Failed to perform delivery with postage: \n#{e.inspect}"
      raise e
    end
  
  
  
  
    # Violent override of the default ActionMailer deliver! method
    # So we can return the response from the api call
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
  
  
    # Don't render any template if the file is not there
    def render_message(method_name, body)
      case method_name
      when ActionView::ReloadableTemplate 
        super if File.exists?(method_name.relative_path).to_yaml
      else
        super if File.exists?(method_name)
      end
    end
  
  end
end