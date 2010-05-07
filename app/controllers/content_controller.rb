class ContentController < ApplicationController
  def home
    if request.post?
      @result = UserMailer::deliver_message(params)
      if @result.response['status'] == 'ok'
        flash.now[:notice] = "Your message has been sent. Check your project in PostageApp"
      else
        flash.now[:error] = "There was an error sending your message"
      end
    end
  end
end
