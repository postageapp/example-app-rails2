require 'postageapp/mailer'

class Mailer < PostageApp::Mailer
  
  def message(params)
    headers 'Reply-To' => 'sender@examlple.com'
    subject params[:subject]
    recipients params[:to] => { 'name' => params[:variable] }
    from 'sender@example.com'
    body :text_content => params[:text], :html_content => params[:html]
  end
  
end
