class UserMailer < Postage::Mailer
  
  def message(params)
    recipients params[:email] => {'name' => params[:variable]}
    from       'somebody@somewhere.com'
    body       :plain_text_message => params[:plain_text], :html_message => params[:html]
    headers    'Reply-to' => 'somebody@somewhere.com'
    subject    params[:subject]
  end
  
end