class WelcomeController < ApplicationController
  
  def index
    @api_key = PostageApp.config.api_key
    @api_key = nil if @api_key.blank? || @api_key == 'PROJECT_API_KEY'
    
    @subject  = params[:subject] || 'Hello {{name}}'
    @to       = params[:to] || 'me@example.com'
    @variable = params[:variable] || 'Tester'
    @html     = params[:html] || "<h1>Hi, {{name}}</h1>\n<p>This is a test.</p>"
    @text     = params[:text] || "Hi, {{name}}\nThis is a test."
    
    @response = Mailer.deliver_message(params) if request.post?
  end
  
end
